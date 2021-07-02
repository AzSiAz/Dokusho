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
    
    convenience init(context ctx: NSManagedObjectContext, title: String) {
        self.init(entity: Self.entity(), insertInto: ctx)
        
        self.title = title
    }
    
    static func fetchRequest() -> NSFetchRequest<MangaAlternatesName> {
        return NSFetchRequest<MangaAlternatesName>(entityName: "MangaAlternatesName")
    }
}


extension MangaAlternatesName {
    
    static func fetchMany(names: [String], ctx: NSManagedObjectContext) -> [MangaAlternatesName]? {
        let req = MangaAlternatesName.fetchRequest()
        req.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(format: "title IN %@", names),
        ])
        
        return try? ctx.fetch(req)
    }
    
    static func createFromSource(manga: Manga, titles: [String], context ctx: NSManagedObjectContext) {
        let alreadyInDB = Self.fetchMany(names: titles, ctx: ctx)
        
        return titles.forEach { raw in
            guard let found = alreadyInDB?.first(where: { raw == $0.title }) else {
                let alt = MangaAlternatesName(context: ctx, title: raw)
                
                alt.addToManga(manga)
                manga.addToAlternatesNames(alt)

                return
            }
            
            manga.addToAlternatesNames(found)
            found.addToManga(manga)
        }
    }
    
    func addToManga(_ manga: Manga) {
        self.manga = manga
    }
}
