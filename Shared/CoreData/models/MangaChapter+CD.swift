//
//  MangaChapter+CD.swift
//  Dokusho (iOS)
//
//  Created by Stephan Deumier on 28/06/2021.
//

import Foundation
import CoreData
import SwiftUI

@objc(Mangachapter)
class MangaChapter: NSManagedObject {
    @NSManaged var id: String?
    @NSManaged var title: String?
    @NSManaged var position: Int64
    @NSManaged var statusRaw: String?
    @NSManaged var dateSourceUpload: Date?
    @NSManaged var readAt: Date?
    
    @NSManaged var manga: Manga?
    
    convenience init(context ctx: NSManagedObjectContext, id: String, title: String, position: Int64, status: MangaChapter.Status, dateSourceUpload: Date, manga: Manga?) {
        self.init(entity: Self.entity(), insertInto: ctx)

        self.id = id
        self.title = title
        self.position = position
        self.status = status
        self.dateSourceUpload = dateSourceUpload
        if let manga = manga {
            self.manga = manga
        }
    }
}

extension MangaChapter: Identifiable {}

extension MangaChapter {
    enum Status: String, CaseIterable {
        case unread
        case read
    }
    
    var status: Status {
        get {
            return .init(rawValue: self.statusRaw ?? "") ?? .unread
        }
        
        set {
            self.statusRaw = newValue.rawValue
        }
    }
    
    static func createFromSource(manga: Manga, chapters: [SourceChapter], context ctx: NSManagedObjectContext) {
        return chapters.enumerated().forEach { (index, chapter) in
            let old = manga.chapters?.first { ($0.id == chapter.id) }
            
            if let old = old {
                old.title = chapter.name
                old.id = chapter.id
                old.position = Int64(index)
                old.dateSourceUpload = chapter.dateUpload
            }

            else {
                let c = MangaChapter(
                    context: ctx,
                    id: chapter.id,
                    title: chapter.name,
                    position: Int64(index),
                    status: .unread,
                    dateSourceUpload: chapter.dateUpload,
                    manga: manga
                )
                
                manga.addToChapters(c)
            }
        }
    }
}

extension MangaChapter {
    static func fetchRequest() -> NSFetchRequest<MangaChapter> {
        return NSFetchRequest<MangaChapter>(entityName: "MangaChapter")
    }
    
    enum StatusFilter {
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
    
    static func fetchChaptersForManga(mangaId: String, status: StatusFilter = .all, ascending: Bool = true) -> NSFetchRequest<MangaChapter> {
        let req = MangaChapter.fetchRequest()
        
        req.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(format: "manga.id = %@", mangaId),
            NSPredicate(format: "statusRaw IN %@", status == .all ? [Status.unread.rawValue, Status.read.rawValue] : [Status.unread.rawValue])
        ])
        
        req.sortDescriptors = [
            NSSortDescriptor(keyPath: \MangaChapter.position, ascending: ascending)
        ]
        
        return req
    }
    
    static func fetchChaptersHistory() -> NSFetchRequest<MangaChapter>{
        let req = MangaChapter.fetchRequest()
        
        req.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(format: "statusRaw = %@", Status.read.rawValue),
            NSPredicate(format: "manga != nil")
        ])
        
        req.sortDescriptors = [
            NSSortDescriptor(keyPath: \MangaChapter.readAt, ascending: false)
        ]
        
        req.relationshipKeyPathsForPrefetching = [
            #keyPath(MangaChapter.manga)
        ]
        
        req.fetchBatchSize = 50
        
        return req
    }
}
