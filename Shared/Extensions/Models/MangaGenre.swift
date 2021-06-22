//
//  MangaGenre.swift
//  Dokusho (iOS)
//
//  Created by Stephan Deumier on 21/06/2021.
//

import Foundation
import CoreData

extension MangaGenre {
    static func fromSource(genres: [String], context ctx: NSManagedObjectContext) -> [MangaGenre] {
        return genres.map { genre in
            let g = MangaGenre(context: ctx)
            g.name = genre
            
            return g
        }
    }
}
