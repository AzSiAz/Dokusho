//
//  MangaAuthor.swift
//  Dokusho (iOS)
//
//  Created by Stephan Deumier on 21/06/2021.
//

import Foundation
import CoreData

extension MangaAuthor {
    static func fromSource(authors: [String], context ctx: NSManagedObjectContext) -> [MangaAuthor] {
        return authors.map { author in
            let a = MangaAuthor(context: ctx)
            a.name = author
            
            return a
        }
    }
}
