//
//  ChapterEntity.swift
//  ChapterEntity
//
//  Created by Stephan Deumier on 18/08/2021.
//

import Foundation
import CoreData
import MangaScraper

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
    static func chaptersForManga(ctx: NSManagedObjectContext, manga: NSManagedObjectID, source: NSManagedObjectID) -> [ChapterEntity] {
        let req = Self.fetchRequest()
        
        req.predicate = ChapterEntity.forMangaPredicate(manga: manga)
        
        return try! ctx.fetch(req)
    }
    
    static func chaptersForManga(manga: NSManagedObjectID, ascendingOrder: Bool) -> NSFetchRequest<ChapterEntity> {
        let req = Self.fetchRequest()
        
        req.predicate = ChapterEntity.forMangaPredicate(manga: manga)
        req.sortDescriptors = [NSSortDescriptor(keyPath: \ChapterEntity.position, ascending: ascendingOrder)]
        req.fetchLimit = 0
        req.fetchBatchSize = 0
        
        return req
    }
}

extension ChapterEntity {
    static func forMangaPredicate(manga: NSManagedObjectID) -> NSPredicate {
        return NSPredicate(format: "%K = %@", #keyPath(ChapterEntity.manga), manga)
    }
    
    static func forSourcePredicate(source: SourceEntity) -> NSPredicate {
        return NSPredicate(format: "%K = %i", #keyPath(ChapterEntity.manga.source), source)
    }
    
    static func positionOrder(order: SortOrder = .forward) -> SortDescriptor<ChapterEntity> {
        return SortDescriptor<ChapterEntity>(\.position, order: order)
    }
}
