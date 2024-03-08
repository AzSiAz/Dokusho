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
        throw "Not done"
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
        var collection: SerieCollection
        var series: [SerieWithChapters]
    }
    
    public struct SerieWithChapters: Codable {
        var serie: Serie
        var chapters: [SerieChapter]
    }
}

public struct BackupTask<T> {
    var serieBackup: T
    var collection: SerieCollection
}

public typealias BackupResultV2 = Result<BackupTask<BackupV2.SerieWithChapters>, Error>

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
                        position: $0.position,
                        language: $0.language
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

    public func importV1Backup(backup: BackupV2.BackupData, harmonic: Harmonic, scraperService: ScraperService) async throws {}

    public func importV2Backup(backup: BackupV2.BackupData, harmonic: Harmonic) async throws {
        withAnimation {
            self.isImporting = true
        }

        try await withThrowingTaskGroup(of: BackupResultV2.self) { group in
            for scraperBackup in backup.scrapers {
//                let foundScraper = ScraperService.shared.getSource(sourceId: scraperBackup.id)
//                let icon = foundScraper?.icon ?? .init(string: "https://google.com/favicon.ico")!
//                let language = Scraper.Language(from: foundScraper?.language ?? .all)
                let scraper = Scraper(backup: scraperBackup)
                try await harmonic.save(record: scraper)
            }

            for collectionBackup in backup.collections {
                let collection = collectionBackup.collection
                try await harmonic.save(record: collection)

                withAnimation {
                    self.total += Double(collectionBackup.series.count)
                }

                for serieBackup in collectionBackup.series {
                    group.addTask(priority: .background) { [collection] in
                        return .success(BackupTask(serieBackup: serieBackup, collection: collection))
                    }
                }
            }

            for try await taskResult in group {
                switch(taskResult) {
                case .failure(let error): Logger.backup.error("\(error.localizedDescription)")
                case .success(let task):
                    Logger.backup.info("Restoring \(task.serieBackup.serie.title)")
                    do {
                        try await harmonic.save(record: task.serieBackup.serie)
                        try await harmonic.save(records: task.serieBackup.chapters)

                        withAnimation {
                            self.progress += 1
                        }
                    } catch(let err) {
                        Logger.backup.error("Error importing manga \(task.serieBackup.serie.title): \(err.localizedDescription)")
                    }
                }
            }
        }

        withAnimation {
            self.isImporting = false
        }
    }
}
