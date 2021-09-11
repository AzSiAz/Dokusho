//
//  ChapterEntity.swift
//  ChapterEntity
//
//  Created by Stephan Deumier on 18/08/2021.
//

import Foundation
import CoreData
import MangaScraper

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
        return status != .read
    }
    
    convenience init(ctx: NSManagedObjectContext, data: SourceChapter, position: Int32, source: SourceEntity) {
        self.init(entity: Self.entity(), insertInto: ctx)
        
        self.key = "\(source.sourceId)%%\(data.id)"
        self.chapterId = data.id
        self.dateSourceUpload = data.dateUpload
        self.position = position
        self.title = data.name
    }
    
    func markAs(newStatus: ChapterStatus, date: Date = .now) {
        if newStatus == .read { self.readAt = date }
        if newStatus == .unread { self.readAt = nil }
        
        self.status = newStatus
    }
    
    func updateFromBackup(chapterBackup: ChapterBackup) {
        self.readAt = chapterBackup.readAt
        self.status = .read
    }
}

extension ChapterEntity {
    static func chaptersForManga(ctx: NSManagedObjectContext, manga: NSManagedObjectID, source: NSManagedObjectID) -> [ChapterEntity] {
        let req = Self.fetchRequest()
        
        req.predicate = ChapterEntity.forMangaPredicate(manga: manga)
        
        return try! ctx.fetch(req)
    }
    
    static func chaptersListForMangaPredicate(manga: NSManagedObjectID, filter: ChapterStatusFilter = .all) -> NSPredicate {
        var predicate: [NSPredicate] = [forMangaPredicate(manga: manga)]
        if filter != .all { predicate.append(forChapterStatusPredicate(filter: filter)) }
        
        return NSCompoundPredicate(andPredicateWithSubpredicates: predicate)
    }
}

extension ChapterEntity {
    static func forMangaPredicate(manga: NSManagedObjectID) -> NSPredicate {
        return NSPredicate(format: "%K = %@", #keyPath(ChapterEntity.manga), manga)
    }
    
    static func forSourcePredicate(source: SourceEntity) -> NSPredicate {
        return NSPredicate(format: "%K = %i", #keyPath(ChapterEntity.manga.source), source)
    }
    
    static func forChapterStatusPredicate(filter: ChapterStatusFilter) -> NSPredicate {
        return NSPredicate(format: "%K IN %@", #keyPath(ChapterEntity.statusRaw), filter == .all ? [ChapterStatus.read.rawValue, ChapterStatus.unread.rawValue] : [ChapterStatus.unread.rawValue])
    }
    
    static func positionOrder(order: SortOrder = .forward) -> SortDescriptor<ChapterEntity> {
        return SortDescriptor<ChapterEntity>(\.position, order: order)
    }
}
