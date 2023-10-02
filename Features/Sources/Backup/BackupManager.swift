//
//  Backup.swift
//  Dokusho
//
//  Created by Stef on 21/12/2021.
//

import Foundation
import OSLog
import SwiftUI
import UniformTypeIdentifiers
import MangaScraper
import DataKit
import Common

public struct Backup: FileDocument {
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
}

public struct BackupData: Codable {
    var collections: [BackupCollectionData]
    var scrapers: [Scraper]
}

public struct BackupCollectionData: Codable {
    var collection: MangaCollection
    var mangas: [MangaWithChapters]
}

public struct MangaWithChapters: Codable {
    var manga: Manga
    var chapters: [MangaChapter]
}


public struct BackupTask {
    var mangaBackup: MangaWithChapters
    var collection: MangaCollection
}

public typealias BackupResult = Result<BackupTask, Error>

@Observable
public class BackupManager {
    public static let shared = BackupManager()

    private let database = AppDatabase.shared.database
    
    public var isImporting: Bool
    public var total: Double
    public var progress: Double
    
    private init() {
        self.isImporting = false
        self.total = 0
        self.progress = 0
    }
    
    public func createBackup() -> BackupData {
        var backupCollections = [BackupCollectionData]()
        var scrapers = [Scraper]()

        do {
            try database.read { db in
                scrapers = try Scraper.all().fetchAll(db)
                let collections = try MangaCollection.all().fetchAll(db)
                
                for collection in collections {
                    let mangas = try Manga.all().forCollectionId(collection.id).fetchAll(db)
                    var mangasBackup = [MangaWithChapters]()

                    for manga in mangas {
                        let chapters = try MangaChapter.all().forMangaId(manga.id).fetchAll(db)
                        mangasBackup.append(.init(manga: manga, chapters: chapters))
                    }
                    
                    backupCollections.append(.init(collection: collection, mangas: mangasBackup))
                }
            }
        } catch(let err) {
            Logger.backup.error("Error creating backup: \(err.localizedDescription)")
        }
        
        return .init(collections: backupCollections, scrapers: scrapers)
    }

    public func importBackup(backup: BackupData) async {
        withAnimation {
            self.isImporting = true
        }

        await withTaskGroup(of: BackupResult.self) { group in
            
            for scraper in backup.scrapers {
                let _ = try? await database.write({ try Scraper.fetchOrCreateFromBackup(db: $0, backup: scraper) })
            }
            
            for collectionBackup in backup.collections {
                guard let collection = try? await database.write({ try MangaCollection.fetchOrCreateFromBackup(db: $0, backup: collectionBackup.collection) }) else { continue }
                
                withAnimation {
                    self.total += Double(collectionBackup.mangas.count)
                }

                for mangaBackup in collectionBackup.mangas {
                    group.addTask(priority: .background) {
                        return .success(BackupTask(mangaBackup: mangaBackup, collection: collection))
                    }
                }
            }
            
            
            for await taskResult in group {
                switch(taskResult) {
                case .failure(let error): Logger.backup.error("\(error.localizedDescription)")
                case .success(let task):
                    Logger.backup.info("Restoring \(task.mangaBackup.manga.title)")                    
                    do {
                        try await database.write { db in
                            let _ = try task.mangaBackup.manga.saved(db)
                            try task.mangaBackup.chapters.forEach { try $0.save(db) }
                        }

                        withAnimation {
                            self.progress += 1
                        }
                    } catch(let err) {
                        Logger.backup.error("Error importing manga \(task.mangaBackup.manga.title): \(err.localizedDescription)")
                    }
                }
            }
        }
        
        withAnimation {
            self.isImporting = false
        }
    }
}
