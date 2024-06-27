import Foundation
import OSLog
import SwiftUI
import UniformTypeIdentifiers
import SerieScraper
import DataKit
import Common

public struct BackupV2: FileDocument {
    public static var readableContentTypes = [UTType.json]
    public static var writableContentTypes = [UTType.json]
    
    var data: BackupData
    
    public init(configuration: ReadConfiguration) throws {
        throw "Should not be used"
    }

    public init(data: BackupData) {
        self.data = data
    }
    
    public func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let data = try JSONEncoder().encode(data)
        return FileWrapper(regularFileWithContents: data)
    }
    
    public struct BackupData: Codable {
        var collections: [BackupCollectionData]
        var scrapers: [Scraper.Backup.V2]
    }
    
    public struct BackupCollectionData: Codable {
        var collection: SerieCollection.Backup.V2
        var series: [SerieWithChapters]
    }
    
    public struct SerieWithChapters: Codable {
        var serie: Serie.Backup.V2
        var chapters: [SerieChapter.Backup.V2]
    }
    
    public struct Task {
        var serie: SerieWithChapters
        var collection: SerieCollection
    }
}

public struct BackupV1: FileDocument {
    public static var readableContentTypes = [UTType.json]
    public static var writableContentTypes = [UTType.json]
    
    var data: BackupData
    
    public init(configuration: ReadConfiguration) throws {
        throw "Should not be used"
    }
    
    public init(data: BackupData) {
        self.data = data
    }
    
    public func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let data = try JSONEncoder().encode(data)
        return FileWrapper(regularFileWithContents: data)
    }
    
    public struct BackupData: Codable {
        var collections: [BackupCollectionData]
        var scrapers: [Scraper.Backup.V1]
    }
    
    public struct BackupCollectionData: Codable {
        var collection: SerieCollection.Backup.V1
        var mangas: [MangaWithChapters]
    }
    
    public struct MangaWithChapters: Codable {
        var manga: Serie.Backup.V1
        var chapters: [SerieChapter.Backup.V1]
    }
    
    public struct Task {
        var serie: MangaWithChapters
        var collection: SerieCollection
    }
}

typealias BackupResultV1 = Result<BackupV1.Task, Error>
typealias BackupResultV2 = Result<BackupV2.Task, Error>

@Observable
public class BackupManager {
    public var isImporting: Bool = false
    public var total: Double = 0
    public var progress: Double = 0
    
    public init() {}
    
    public func createBackup(harmonic: Harmonic) -> BackupV2.BackupData {
        var backupCollections = [BackupV2.BackupCollectionData]()
        var scrapers = [Scraper.Backup.V2]()

        do {
            try harmonic.reader.read { db in
                scrapers = try Scraper.all().fetchAll(db).map {
                    Scraper.Backup.V2(
                        id: $0.id,
                        name: $0.name,
                        icon: $0.icon,
                        isActive: $0.isActive,
                        language: $0.language,
                        position: $0.position
                    )
                }
                
                let collections = try SerieCollection.all().fetchAll(db)

                for collection in collections {
                    let series = try Serie.all().forSerieCollectionID(collection.id).fetchAll(db)
                    var seriesBackup = [BackupV2.SerieWithChapters]()

                    for serie in series {
                        let chapters = try SerieChapter.all().whereSerie(serieID: serie.id).fetchAll(db)
                        seriesBackup.append(.init(serie: serie, chapters: chapters))
                    }
                    
                    backupCollections.append(.init(collection: collection, series: seriesBackup))
                }
            }
        } catch(let err) {
            Logger.backup.error("Error creating backup: \(err.localizedDescription)")
        }
        
        return .init(collections: backupCollections, scrapers: scrapers)
    }

    public func importV1Backup(backup: BackupV1.BackupData, harmonic: Harmonic, scraperService: ScraperService) async throws {
        withAnimation {
            self.isImporting = true
        }

        try await withThrowingTaskGroup(of: BackupResultV1.self) { group in
            for scraperBackup in backup.scrapers {
                guard let foundSource = ScraperService.shared.getSource(sourceId: scraperBackup.id) else { throw "Can't handle scraper \(scraperBackup)" }
                let scraper = Scraper(backup: scraperBackup, icon: foundSource.icon, language: Scraper.Language(from: foundSource.language))

                try await harmonic.save(record: scraper)
            }
            
            for collectionBackup in backup.collections {
                let collection = SerieCollection(backup: collectionBackup.collection)
                try await harmonic.save(record: collection)
                
                withAnimation {
                    self.total += Double(collectionBackup.mangas.count)
                }
                
                for serieBackup in collectionBackup.mangas {
                    group.addTask(priority: .background) { [collection] in
                        return .success(.init(serie: serieBackup, collection: collection))
                    }
                }
            }
            
            for try await taskResult in group {
                switch(taskResult) {
                case .failure(let error): Logger.backup.error("\(error.localizedDescription)")
                case .success(let task):
                    Logger.backup.info("Restoring \(task.serie.manga.title)")
                    do {
                        guard let scraperID = task.serie.manga.scraperId else { throw "Scraper for serie should be defined" }
                        guard let foundSource = ScraperService.shared.getSource(sourceId: scraperID) else { throw "Source should be found to restore correctly on V1 backup" }
                        guard let sourceSerie = try? await foundSource.fetchSerieDetail(serieId: task.serie.manga.mangaId) else { throw "Serie should still exist on source" }

                        var serie = Serie(backup: task.serie.manga, scraperID: scraperID, serieCollectionID: task.collection.id)
                        serie.update(from: sourceSerie)
                        try await harmonic.save(record: serie)
                        
                        let chapters = task.serie.chapters.map { backup in
                            var chapter = SerieChapter(backup: backup, serieID: serie.id, chapter: Float(backup.position), volume: 0)
                            if let sourceChapter = sourceSerie.chapters.first(where: { $0.id == "\(scraperID)@@\(backup.chapterId)" }) {
                                chapter.update(from: sourceChapter)
                            }

                            return chapter
                        }

                        try await harmonic.save(records: chapters)

                        withAnimation {
                            self.progress += 1
                        }
                    } catch(let err) {
                        Logger.backup.error("Error importing manga \(task.serie.manga.title): \(err.localizedDescription)")
                    }
                }
            }
        }
        
        withAnimation {
            self.isImporting = false
        }
    }

    public func importV2Backup(backup: BackupV2.BackupData, harmonic: Harmonic) async throws {
        withAnimation {
            self.isImporting = true
        }

        try await withThrowingTaskGroup(of: BackupResultV2.self) { group in
            for scraperBackup in backup.scrapers {
                let scraper = Scraper(backup: scraperBackup)
                try await harmonic.save(record: scraper)
            }

            for collectionBackup in backup.collections {
                let collection = SerieCollection(backup: collectionBackup.collection)
                try await harmonic.save(record: collection)

                withAnimation {
                    self.total += Double(collectionBackup.series.count)
                }

                for serieBackup in collectionBackup.series {
                    group.addTask(priority: .background) { [collection] in
                        return .success(BackupV2.Task(serie: serieBackup, collection: collection))
                    }
                }
            }

            for try await taskResult in group {
                switch(taskResult) {
                case .failure(let error): Logger.backup.error("\(error.localizedDescription)")
                case .success(let task):
                    Logger.backup.info("Restoring \(task.serie.serie.title)")
                    do {
                        try await harmonic.save(record: task.serie.serie)
                        try await harmonic.save(records: task.serie.chapters)

                        withAnimation {
                            self.progress += 1
                        }
                    } catch(let err) {
                        print(err)
                        Logger.backup.error("Error importing manga \(task.serie.serie.title): \(err.localizedDescription)")
                    }
                }
            }
        }

        withAnimation {
            self.isImporting = false
        }
    }
}
