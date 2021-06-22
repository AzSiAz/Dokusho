//
//  MangaAlternatesName.swift
//  Dokusho (iOS)
//
//  Created by Stephan Deumier on 21/06/2021.
//

import Foundation
import CoreData

extension MangaAlternatesName {
    static func fromSource(titles: [String], context ctx: NSManagedObjectContext) -> [MangaAlternatesName] {
        return titles.map { title in
            let t = MangaAlternatesName(context: ctx)
            t.title = title

            return t
        }
    }
}
