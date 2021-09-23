//
//  AlternateTitlesEntity.swift
//  AlternateTitlesEntity
//
//  Created by Stephan Deumier on 18/08/2021.
//

import Foundation
import CoreData

extension AlternateTitlesEntity {
    convenience init(ctx: NSManagedObjectContext, title: String, sourceId: Int) {
        self.init(entity: Self.entity(), insertInto: ctx)
        
        self.title = title
        self.key = Self.generateKey(title: title, sourceId: sourceId)
    }
    
    static func fetchOne(ctx: NSManagedObjectContext, title: String, sourceId: Int) -> AlternateTitlesEntity? {
        let req = Self.fetchRequest()
        
        req.fetchLimit = 1
        req.predicate = Self.keyPredicate(title: title, sourceId: sourceId)
        
        return try? ctx.fetch(req).first
    }
    
    static func fromSourceSource(ctx: NSManagedObjectContext, title: String, sourceId: Int, manga: MangaEntity) -> AlternateTitlesEntity {
        let d: AlternateTitlesEntity
        if let found = Self.fetchOne(ctx: ctx, title: title, sourceId: sourceId) {
            d = found
        } else {
            d = AlternateTitlesEntity(ctx: ctx, title: title, sourceId: sourceId)
        }
        
        d.manga = manga
        
        return d
    }
}

extension AlternateTitlesEntity {
    static func keyPredicate(title: String, sourceId: Int) -> NSPredicate {
        return NSPredicate(format: "%K = %@", #keyPath(AlternateTitlesEntity.key), Self.generateKey(title: title, sourceId: sourceId))
    }
}
