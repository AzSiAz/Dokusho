//
//  ChapterEntity.swift
//  ChapterEntity
//
//  Created by Stephan Deumier on 18/08/2021.
//

import Foundation
import CoreData
import MangaSources

enum ChapterStatus: String, CaseIterable {
    case unread = "Unread"
    case read = "Read"
}

enum ChapterStatusFilter {
    case all
    case unread
    
    mutating func toggle() {
        if self == .all {
            self = .unread
        }
        else {
            self = .all
        }
    }
    
}

extension ChapterEntity {
    var isUnread: Bool {
        return statusRaw != ChapterStatus.read.rawValue
    }
    
    convenience init(ctx: NSManagedObjectContext, data: SourceChapter, position: Int32, source: SourceEntity) {
        self.init(entity: Self.entity(), insertInto: ctx)
        
        self.key = "\(source.sourceId)%%\(data.id)"
        self.chapterId = data.id
        self.dateSourceUpload = data.dateUpload
        self.position = position
        self.title = data.name
    }
    
    func markAs(newStatus: ChapterStatus) {
        if newStatus == .read { self.readAt = .now }
        if newStatus == .unread { self.readAt = nil }
        
        self.statusRaw = newStatus.rawValue
    }
    
    func updateFromBackup(chapterBackup: ChapterBackup) {
        self.readAt = chapterBackup.readAt
        self.statusRaw = ChapterStatus.read.rawValue
    }
}

extension ChapterEntity {
    static func chaptersForManga(ctx: NSManagedObjectContext, manga: MangaEntity, source: SourceEntity) -> [ChapterEntity] {
        let req = Self.fetchRequest()
        
        req.predicate = ChapterEntity.forMangaAndSourcePredicate(mangaId: manga.mangaId!, sourceId: source.sourceId)
        
        return try! ctx.fetch(req)
    }
}

extension ChapterEntity {
    static func forMangaAndSourcePredicate(mangaId: String, sourceId: Int32) -> NSPredicate {
        return NSCompoundPredicate(andPredicateWithSubpredicates: [
            ChapterEntity.forMangaPredicate(mangaId: mangaId),
            ChapterEntity.forSourcePredicate(sourceId: sourceId)
        ])
    }
    
    static func forMangaPredicate(mangaId: String) -> NSPredicate {
        return NSPredicate(format: "%K = %@", #keyPath(ChapterEntity.manga.mangaId), mangaId)
    }
    
    static func forSourcePredicate(sourceId: Int32) -> NSPredicate {
        return NSPredicate(format: "%K = %i", #keyPath(ChapterEntity.manga.source.sourceId), sourceId)
    }
    
    static func positionOrder(order: SortOrder = .forward) -> SortDescriptor<ChapterEntity> {
        return SortDescriptor<ChapterEntity>(\.position, order: order)
    }
}
