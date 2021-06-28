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
}


extension MangaGenre {
    static func fromSource(genres: [String], context ctx: NSManagedObjectContext) -> [MangaGenre] {
        return genres.map { genre in
            let g = MangaGenre(context: ctx)
            g.name = genre
            
            return g
        }
    }
}
