//
//  MangaAuthor+CD.swift
//  Dokusho (iOS)
//
//  Created by Stephan Deumier on 28/06/2021.
//

import Foundation
import CoreData

@objc(MangaAuthor)
class MangaAuthor: NSManagedObject {
    @NSManaged var name: String?
    
    @NSManaged var mangas: Set<Manga>?
    
    convenience init(context ctx: NSManagedObjectContext, name: String) {
        self.init(entity: Self.entity(), insertInto: ctx)
        
        self.name = name
    }
    
    static func fetchRequest() -> NSFetchRequest<MangaAuthor> {
        return NSFetchRequest<MangaAuthor>(entityName: "MangaAuthor")
    }
}

extension MangaAuthor {
    static func fetchMany(names: [String], ctx: NSManagedObjectContext) -> [MangaAuthor]? {
        let req = MangaAuthor.fetchRequest()
        req.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(format: "name IN %@", names),
        ])
        
        return try? ctx.fetch(req)
    }
    
    static func createFromSource(manga: Manga, names: [String], context ctx: NSManagedObjectContext) {
        let alreadyInDB = Self.fetchMany(names: names, ctx: ctx)
        
        return names.forEach { raw in
            guard let found = alreadyInDB?.first(where: { raw == $0.name }) else {
                let author = MangaAuthor(context: ctx, name: raw)
                
                author.addToMangas(manga)
                manga.addToAuthors(author)
                return
            }
            
            manga.addToAuthors(found)
            found.addToMangas(manga)
        }
    }
    
    func addToMangas(_ manga: Manga) {
        guard self.mangas?.contains(manga) == false else { return }
        
        self.mangas?.insert(manga)
    }
}
