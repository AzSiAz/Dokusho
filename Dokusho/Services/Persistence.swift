//
//  Persistence.swift
//  Dokusho
//
//  Created by Stephan Deumier on 17/08/2021.
//

import CoreData
import OSLog
import MangaScraper

struct ChapterBackup: Codable {
    var id: String
    var readAt: Date
}

struct MangaBackup: Codable {
    var id: String
    var sourceId: Int
    var readChapter: [ChapterBackup]
}

struct CollectionBackup: Codable {
    var id: UUID?
    var name: String
    var position: Int
    var mangas: [MangaBackup]
}


struct BackupTask {
    var mangaBackup: MangaBackup
    var collection: CollectionEntity
}

typealias BackupResult = Result<BackupTask, Error>

class PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentContainer

    init() {
        container = NSPersistentContainer(name: "Dokusho")
        
        container.persistentStoreDescriptions.first!.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
        
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                Logger.persistence.error("Unresolved error \(error) with \(error.userInfo)")
                fatalError()
            }
            
            self.container.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
            self.container.viewContext.automaticallyMergesChangesFromParent = true
        }
    }
    
    func backgroundCtx() -> NSManagedObjectContext {
        let ctx = container.newBackgroundContext()
        
        ctx.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        ctx.automaticallyMergesChangesFromParent = true
        
        return ctx
    }
    
    func createBackup() -> [CollectionBackup] {
        let ctx = self.backgroundCtx()

        let collections = CollectionEntity.fetchMany(ctx: ctx)
        
        return collections.map { collection -> CollectionBackup in
            let mangaBackup: [MangaBackup] = collection.mangas!.map { manga in
                let chapterBackup: [ChapterBackup] = manga.chapters!.filter { !$0.isUnread }.map { chapter in
                    return ChapterBackup(id: chapter.chapterId!, readAt: chapter.readAt ?? chapter.dateSourceUpload ?? .now)
                }
                return MangaBackup(id: manga.mangaId!, sourceId: Int(manga.source!.sourceId), readChapter: chapterBackup)
            }
            
            return CollectionBackup(id: collection.uuid!, name: collection.name!, position: Int(collection.position), mangas: mangaBackup)
        }
    }
    
    func importBackup(backup: [CollectionBackup]) async {
        let ctx = self.backgroundCtx()
        
        await withTaskGroup(of: BackupResult.self) { group in
            for collectionBackup in backup {
                let collection = CollectionEntity.fromBackup(info: collectionBackup, ctx: ctx)
                try? ctx.save()
                
                for mangaBackup in collectionBackup.mangas {
                    group.addTask(priority: .background) {
                        return .success(BackupTask(mangaBackup: mangaBackup, collection: collection))
                    }
                }
            }
            
            for await taskResult in group {
                switch(taskResult) {
                    case .failure(let error):
                        Logger.backup.error("\(error.localizedDescription)")
                    case .success(let task):
                        Logger.backup.info("Restoring \(task.mangaBackup.id)")
                        
                        guard let source = SourceEntity.fetchOne(sourceId: task.mangaBackup.sourceId, ctx: ctx) else { continue }
                        
                        guard let sourceInfo = try? await source.getSource().fetchMangaDetail(id: task.mangaBackup.id) else { continue }
                        
                        guard let manga = try? MangaEntity.updateFromSource(ctx: ctx, data: sourceInfo, source: source) else { continue }
                        
                        manga.importChapterBackup(chaptersBackup: task.mangaBackup.readChapter)
                        task.collection.addToMangas(manga)
                        
                        try? ctx.save()
                }
            }
        }
        
        try? ctx.save()
    }
}
