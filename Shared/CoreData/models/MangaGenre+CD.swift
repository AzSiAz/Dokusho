//
//  MangaGenre+CD.swift
//  Dokusho (iOS)
//
//  Created by Stephan Deumier on 28/06/2021.
//

import Foundation
import CoreData

@objc(MangaGenre)
class MangaGenre: NSManagedObject {
    @NSManaged var name: String?
    
    @NSManaged var mangas: Set<Manga>?
    
    convenience init(context ctx: NSManagedObjectContext, name: String) {
        self.init(entity: Self.entity(), insertInto: ctx)
        
        self.name = name
    }
    
    static func fetchRequest() -> NSFetchRequest<MangaGenre> {
        return NSFetchRequest<MangaGenre>(entityName: "MangaGenre")
    }
}


extension MangaGenre {
    static func fetchMany(names: [String], ctx: NSManagedObjectContext) -> [MangaGenre]? {
        let req = MangaGenre.fetchRequest()
        req.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(format: "name IN %@", names),
        ])

        return try? ctx.fetch(req)
    }
    
    static func createFromSource(manga: Manga, names: [String], context ctx: NSManagedObjectContext) {
        let alreadyInDB = Self.fetchMany(names: names, ctx: ctx)

        return names.forEach { raw in
            guard let found = alreadyInDB?.first(where: { raw == $0.name }) else {
                let genre = MangaGenre(context: ctx, name: raw)
                
                genre.addToMangas(manga)
                manga.addToGenres(genre)
                return
            }

            manga.addToGenres(found)
            found.addToMangas(manga)
        }
    }
    
    func addToMangas(_ manga: Manga) {
        guard self.mangas?.contains(manga) == false else { return }

        self.mangas?.insert(manga)
    }
}
