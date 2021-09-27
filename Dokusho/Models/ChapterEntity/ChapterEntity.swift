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

enum ChapterStatusHistory: String {
    case all = "All", read = "Read"
}

extension ChapterEntity {
    var isUnread: Bool {
        return status != .read
    }
    
    convenience init(ctx: NSManagedObjectContext, data: SourceChapter, position: Int32, sourceId: UUID) {
        self.init(entity: Self.entity(), insertInto: ctx)
        
        self.key = "\(sourceId.uuidString)%%\(data.id)"
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
    static func chaptersForManga(ctx: NSManagedObjectContext, manga: NSManagedObjectID) -> [ChapterEntity] {
        let req = Self.fetchRequest()
        
        req.predicate = ChapterEntity.forMangaPredicate(manga: manga)
        
        return try! ctx.fetch(req)
    }
    
    static func chaptersListForMangaPredicate(manga: NSManagedObjectID, filter: ChapterStatusFilter = .all) -> NSPredicate {
        var predicate: [NSPredicate] = [forMangaPredicate(manga: manga)]
        if filter != .all { predicate.append(forChapterStatusFilterPredicate(filter: filter)) }
        
        return NSCompoundPredicate(andPredicateWithSubpredicates: predicate)
    }
    
    static func chapterHistoryPredicate(status: ChapterStatusHistory = .read, searchTerm: String = "") -> NSPredicate {
        let statusFilter = (status == .all ? [ChapterStatus.read, ChapterStatus.unread] : [ChapterStatus.read]).map { $0.rawValue }
        
        var predicate: [NSPredicate] = [
            NSPredicate(format: "%K != nil", #keyPath(ChapterEntity.manga.collection)),
            NSPredicate(format: "%K IN %@", #keyPath(ChapterEntity.statusRaw), statusFilter)
        ]

        if !searchTerm.isEmpty {
            predicate.append(NSCompoundPredicate(orPredicateWithSubpredicates: [
                NSPredicate(format: "%K CONTAINS[cd] %@", #keyPath(ChapterEntity.manga.title), searchTerm),
                NSPredicate(format: "%K CONTAINS[cd] %@", #keyPath(ChapterEntity.manga.alternateTitles.title), searchTerm)
            ]))
        }

        return NSCompoundPredicate(andPredicateWithSubpredicates: predicate)
    }
    
    static func chapterHistoryOrder(status: ChapterStatusHistory = .read) -> [SortDescriptor<ChapterEntity>] {
        return [
            SortDescriptor<ChapterEntity>(status == .read ? \.readAt : \.dateSourceUpload, order: .reverse)
        ]
    }
}

extension ChapterEntity {
    static func forMangaPredicate(manga: NSManagedObjectID) -> NSPredicate {
        return NSPredicate(format: "%K = %@", #keyPath(ChapterEntity.manga), manga)
    }
    
    static func forSourcePredicate(sourceId: UUID) -> NSPredicate {
        return NSPredicate(format: "%K = %@", #keyPath(ChapterEntity.manga.sourceId), sourceId.uuidString)
    }
    
    static func forChapterStatusFilterPredicate(filter: ChapterStatusFilter) -> NSPredicate {
        return NSPredicate(format: "%K IN %@", #keyPath(ChapterEntity.statusRaw), filter == .all ? [ChapterStatus.read.rawValue, ChapterStatus.unread.rawValue] : [ChapterStatus.unread.rawValue])
    }
    
    static func forChapterStatusPredicate(status: [ChapterStatus]) -> NSPredicate {
        return NSPredicate(format: "%K in %@", #keyPath(ChapterEntity.statusRaw), status.map { $0.rawValue })
    }
    
    static func positionOrder(order: SortOrder = .forward) -> SortDescriptor<ChapterEntity> {
        return SortDescriptor<ChapterEntity>(\.position, order: order)
    }
    
    static func readAtOrder(order: SortOrder = .reverse) -> SortDescriptor<ChapterEntity> {
        return SortDescriptor<ChapterEntity>(\.readAt, order: order)
    }
}
