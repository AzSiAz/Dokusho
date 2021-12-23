//
//  Backup.swift
//  Dokusho
//
//  Created by Stef on 21/12/2021.
//

import Foundation
import OSLog

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
    var id: UUID?
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
//        let ctx = self.backgroundCtx()
//        var backup = [CollectionBackup]()
//
//        ctx.performAndWait {
//            let collections = CollectionEntity.fetchMany(ctx: ctx)
//
//            backup = collections.map { collection -> CollectionBackup in
//                let mangaBackup: [MangaBackup] = collection.mangas!.map { manga in
//                    let chapterBackup: [ChapterBackup] = manga.chapters!.filter { !$0.isUnread }.map { chapter in
//                        return ChapterBackup(id: chapter.chapterId!, readAt: chapter.readAt ?? chapter.dateSourceUpload ?? .now)
//                    }
//                    return MangaBackup(id: manga.mangaId!, sourceId: manga.sourceId, readChapter: chapterBackup)
//                }
//
//                return CollectionBackup(id: collection.uuid!, name: collection.name!, position: Int(collection.position), mangas: mangaBackup)
//            }
//        }
//
//        return backup
        return []
    }

    func importBackup(backup: [CollectionBackup]) async {
//        let ctx = self.backgroundCtx()
//
//        await withTaskGroup(of: BackupResult.self) { group in
//            for collectionBackup in backup {
//                let collection = CollectionEntity.fromBackup(info: collectionBackup, ctx: ctx)
//                try? ctx.save()
//
//                for mangaBackup in collectionBackup.mangas {
//                    group.addTask(priority: .background) {
//                        return .success(BackupTask(mangaBackup: mangaBackup, collection: collection))
//                    }
//                }
//            }
//
//            for await taskResult in group {
//                switch(taskResult) {
//                    case .failure(let error):
//                        Logger.backup.error("\(error.localizedDescription)")
//                    case .success(let task):
//                        Logger.backup.info("Restoring \(task.mangaBackup.id)")
//
//                        guard let source = MangaScraperService.shared.getSource(sourceId: task.mangaBackup.sourceId) else { continue }
//
//                        guard let sourceInfo = try? await source.fetchMangaDetail(id: task.mangaBackup.id) else { continue }
//
//                        guard let manga = try? MangaEntity.updateFromSource(ctx: ctx, data: sourceInfo, source: source) else { continue }
//
//                        manga.importChapterBackup(chaptersBackup: task.mangaBackup.readChapter)
//                        task.collection.addToMangas(manga)
//
//                        try? ctx.save()
//                }
//            }
//        }
//
//        try? ctx.save()
    }
}
