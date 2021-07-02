//
//  MangaChapter+CD.swift
//  Dokusho (iOS)
//
//  Created by Stephan Deumier on 28/06/2021.
//

import Foundation
import CoreData

@objc(Mangachapter)
class MangaChapter: NSManagedObject {
    @NSManaged var id: String?
    @NSManaged var title: String?
    @NSManaged var position: Int64
    @NSManaged var statusRaw: String?
    @NSManaged var dateSourceUpload: Date?
    
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
    enum Status: String {
        case reading
        case unread
        case read
        
        func isUnread() -> Bool {
            return self == .read ? false : true
        }
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
