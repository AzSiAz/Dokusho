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
    @NSManaged var position: Int
    @NSManaged var statusRaw: String?
    @NSManaged var dateSourceUpload: Date?
    
    @NSManaged var manga: Manga?
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
    
    static func fromSource(chapters: [SourceChapter], manga: Manga, context ctx: NSManagedObjectContext) {
        return chapters.enumerated().forEach { (index, chapter) in
            let old = manga.chapters?.first { ($0.id == chapter.id) }
            
            if let old = old {
                old.title = chapter.name
                old.id = chapter.id
                old.position = index
                old.dateSourceUpload = chapter.dateUpload
            }
            else {
                let c = MangaChapter(context: ctx)
                
                c.title = chapter.name
                c.id = chapter.id
                c.position = index
                c.status = .unread
                c.dateSourceUpload = chapter.dateUpload
                
                c.manga = manga
                manga.chapters?.insert(c)
            }
        }
    }
}
