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

struct Backup: FileDocument {
    static var readableContentTypes = [UTType.json]
    static var writableContentTypes = [UTType.json]
    
    var data: BackupData
    
    init(configuration: ReadConfiguration) throws {
        throw "Not done"
    }
    
    
    init(data: BackupData) {
        self.data = data
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let data = try! JSONEncoder().encode(data)

        return FileWrapper(regularFileWithContents: data)
    }
}

struct BackupData: Codable {
    var collections: [BackupCollectionData]
    var scrapers: [Scraper]
}

struct BackupCollectionData: Codable {
    var collection: MangaCollection
    var mangas: [MangaWithChapters]
}

struct MangaWithChapters: Codable {
    var manga: Manga
    var chapters: [MangaChapter]
}


struct BackupTask {
    var mangaBackup: MangaWithChapters
    var collection: MangaCollection
}

typealias BackupResult = Result<BackupTask, Error>

struct BackupManager {
    static let shared = BackupManager()
    
    private let database = AppDatabase.shared.database
    
    func createBackup() -> BackupData {
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
            print(err)
        }
        
        return .init(collections: backupCollections, scrapers: scrapers)
    }

    func importBackup(backup: BackupData) async {
        await withTaskGroup(of: BackupResult.self) { group in
            
            for scraper in backup.scrapers {
                let _ = try? await database.write({ try Scraper.fetchOrCreateFromBackup(db: $0, backup: scraper) })
            }
            
            for collectionBackup in backup.collections {
                guard let collection = try? await database.write({ try MangaCollection.fetchOrCreateFromBackup(db: $0, backup: collectionBackup.collection) }) else { continue }
                
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
                    } catch(let err) {
                        print(err)
                    }
                }
            }
        }
    }
}
