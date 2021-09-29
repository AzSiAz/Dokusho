//
//  GenreEntity.swift
//  GenreEntity
//
//  Created by Stephan Deumier on 18/08/2021.
//

import Foundation
import CoreData

extension GenreEntity {
    convenience init(ctx: NSManagedObjectContext, name: String) {
        self.init(entity: Self.entity(), insertInto: ctx)
        
        self.name = name
    }
    
    static func fetchOne(ctx: NSManagedObjectContext, name: String) -> GenreEntity? {
        let req = Self.fetchRequest()
        
        req.fetchLimit = 1
        req.predicate = Self.namePredicate(name: name)
        
        return try? ctx.fetch(req).first
    }
    
    static func fromSourceSource(ctx: NSManagedObjectContext, name: String, manga: MangaEntity) -> GenreEntity {
        let d: GenreEntity
        if let found = Self.fetchOne(ctx: ctx, name: name) {
            d = found
        } else {
            d = GenreEntity(ctx: ctx, name: name)
        }
        
        d.addToMangas(manga)
        
        return d
    }
    
    static func namePredicate(name: String) -> NSPredicate {
        return NSPredicate(format: "%K = %@", #keyPath(GenreEntity.name), name)
    }
}
