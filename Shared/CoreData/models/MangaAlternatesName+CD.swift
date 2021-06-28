//
//  MangaAlternatesName+CD.swift
//  Dokusho (iOS)
//
//  Created by Stephan Deumier on 28/06/2021.
//

import Foundation
import CoreData

@objc(MangaAlternatesName)
class MangaAlternatesName: NSManagedObject {
    @NSManaged var title: String?
    
    @NSManaged var manga: Manga?
}


extension MangaAlternatesName {
    static func fromSource(titles: [String], context ctx: NSManagedObjectContext) -> [MangaAlternatesName] {
        return titles.map { title in
            let t = MangaAlternatesName(context: ctx)
            t.title = title
            
            return t
        }
    }
}
