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
}

extension MangaAuthor {
    static func fromSource(authors: [String], context ctx: NSManagedObjectContext) -> [MangaAuthor] {
        return authors.map { author in
            let a = MangaAuthor(context: ctx)
            a.name = author
            
            return a
        }
    }
}
