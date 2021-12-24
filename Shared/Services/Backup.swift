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

struct Backup: FileDocument {
    static var readableContentTypes = [UTType.json]
    static var writableContentTypes = [UTType.json]
    
    var data: [CollectionBackup]
    
    init(configuration: ReadConfiguration) throws {
        data = []
    }
    
    
    init(data: [CollectionBackup]) {
        self.data = data
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let data = try! JSONEncoder().encode(data)

        return FileWrapper(regularFileWithContents: data)
    }
}

struct ChapterBackup: Codable {
    var id: String
    var readAt: Date
}

struct MangaBackup: Codable {
    var id: String
    var sourceId: UUID
    var readChapter: [ChapterBackup]
}

struct CollectionBackup: Codable {
    var id: UUID
    var name: String
    var position: Int
    var mangas: [MangaBackup]
}


struct BackupTask {
    var mangaBackup: MangaBackup
    var collection: MangaCollection
}

typealias BackupResult = Result<BackupTask, Error>

struct BackupManager {
    static let shared = BackupManager()
    
    private let database = AppDatabase.shared.database
    
    func createBackup() -> [CollectionBackup] {
        var backup = [CollectionBackup]()

        do {
            try database.read { db in
                let collections = try MangaCollection.all().fetchAll(db)
                
                for collection in collections {
                    let mangas = try Manga.all().forCollectionId(collection.id).fetchAll(db)
                    var mangasBackup = [MangaBackup]()

                    for manga in mangas {
                        let readChapters = try MangaChapter.all().onlyRead().forMangaId(manga.id).fetchAll(db)
                        var chaptersBackup = [ChapterBackup]()
                        
                        chaptersBackup += readChapters.map { ch -> ChapterBackup in ChapterBackup(id: ch.chapterId, readAt: ch.readAt ?? ch.dateSourceUpload) }
                        mangasBackup.append(MangaBackup(id: manga.mangaId, sourceId: manga.scraperId!, readChapter: chaptersBackup))
                    }
                    
                    backup.append(CollectionBackup(id: collection.id, name: collection.name, position: collection.position, mangas: mangasBackup))
                }
            }
        } catch(let err) {
            print(err)
        }
        
        return backup
    }

    func importBackup(backup: [CollectionBackup]) async {
        await withTaskGroup(of: BackupResult.self) { group in
            
            for collectionBackup in backup {
                guard let collection = try? await AppDatabase.shared.database.write({ try MangaCollection.fetchOrCreateFromBackup(db: $0, backup: collectionBackup) }) else { continue }
                
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
                    Logger.backup.info("Restoring \(task.mangaBackup.id)")
                    guard let source = MangaScraperService.shared.getSource(sourceId: task.mangaBackup.sourceId) else { continue }
                    guard let sourceInfo = try? await source.fetchMangaDetail(id: task.mangaBackup.id) else { continue }
                    
                    do {
                        try await AppDatabase.shared.database.write { db in
                            let scraper = try Scraper.fetchOne(db, source: source)
                            var manga = try Manga.updateFromSource(db: db, scraper: scraper, data: sourceInfo, readChapters: task.mangaBackup.readChapter)
                            manga.mangaCollectionId = task.collection.id
                            
                            try manga.save(db)
                        }
                    } catch(let err) {
                        print(err)
                    }
                }
            }
        }
    }
}
