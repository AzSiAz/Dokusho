import Foundation
import OSLog
import SwiftUI
import UniformTypeIdentifiers
import SerieScraper
import DataKit
import Common

public struct BackupV1: FileDocument {
    public static var readableContentTypes = [UTType.json]
    public static var writableContentTypes = [UTType.json]
    
    var data: BackupDataV1
    
    public init(configuration: ReadConfiguration) throws {
        throw "Not done"
    }

    public init(data: BackupDataV1) {
        self.data = data
    }
    
    public func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let data = try JSONEncoder().encode(data)
        return FileWrapper(regularFileWithContents: data)
    }
}

public struct BackupDataV1: Codable {
    var collections: [BackupCollectionDataV1]
    var scrapers: [Scraper]
}

public struct BackupCollectionDataV1: Codable {
    var collection: SerieCollection
    var series: [SerieWithChaptersV1]
}

public struct SerieWithChaptersV1: Codable {
    var serie: Serie
    var chapters: [SerieChapter]
}


public struct BackupTask {
    var serieBackup: SerieWithChaptersV1
    var collection: SerieCollection
}

public typealias BackupResult = Result<BackupTask, Error>

@Observable
public class BackupManager {
    public static let shared = BackupManager()
    
    public var isImporting: Bool = false
    public var total: Double = 0
    public var progress: Double = 0
    
    private init() {}
    
    public func createBackup(harmonic: Harmonic) -> BackupDataV1 {
        var backupCollections = [BackupCollectionDataV1]()
        var scrapers = [Scraper]()

        do {
            try harmonic.reader.read { db in
                scrapers = try Scraper.all().fetchAll(db)
                let collections = try SerieCollection.all().fetchAll(db)

                for collection in collections {
                    let series = try Serie.all().forSerieCollectionID(collection.id).fetchAll(db)
                    var seriesBackup = [SerieWithChaptersV1]()

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

    public func importV1Backup(backup: BackupDataV1, harmonic: Harmonic, scraperService: ScraperService) async throws {}

    public func importV2Backup(backup: BackupDataV1, harmonic: Harmonic) async throws {
        withAnimation {
            self.isImporting = true
        }

        try await withThrowingTaskGroup(of: BackupResult.self) { group in
            for scraperBackup in backup.scrapers {
                try await harmonic.save(record: scraperBackup)
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
