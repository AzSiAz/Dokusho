//
//  MangaChapter.swift
//  Dokusho (iOS)
//
//  Created by Stephan Deumier on 21/06/2021.
//

import Foundation
import CoreData

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
        guard let oldChapters = manga.chapters?.allObjects as? [MangaChapter] else { return }
        
        return chapters.enumerated().forEach { (index, chapter) in
            let old = oldChapters.first { ($0.id == chapter.id) }
            
            if let old = old {
                old.title = chapter.name
                old.id = chapter.id
                old.position = Int64(index)
                old.dateSourceUpload = chapter.dateUpload
            }
            else {
                let c = MangaChapter(context: ctx)
                
                c.title = chapter.name
                c.id = chapter.id
                c.position = Int64(index)
                c.status = .unread
                c.dateSourceUpload = chapter.dateUpload
                
                manga.addToChapters(c)
            }
        }
    }
}
