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
    
    static func fromSource(chapters: [SourceChapter], mangaId: String, context ctx: NSManagedObjectContext) -> [MangaChapter] {
        let req = MangaChapter.fetchRequest()
        req.predicate = NSPredicate(format: "manga.id = %@", mangaId)
        let oldChapters = try? ctx.fetch(req)
        
        return chapters.enumerated().map { (index, chapter) in
            let old = oldChapters?.first { ($0.id == chapter.id) }
            
            let c = MangaChapter(context: ctx)
            
            c.title = chapter.name
            c.id = chapter.id
            c.position = Int64(index)
            
            if old?.dateSourceUpload != c.dateSourceUpload {
                if let status = old?.status {
                    c.status = status
                }
                
                c.dateSourceUpload = chapter.dateUpload
            }
            else {
                c.dateSourceUpload = chapter.dateUpload
            }
            
            return c
        }
    }
}
