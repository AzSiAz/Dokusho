//
//  File.swift
//  
//
//  Created by Stephan Deumier on 30/06/2022.
//

import Foundation
import CoreData

extension AlternateTitleEntity {
    static func from(ctx: NSManagedObjectContext, title: String, mangaId: String) -> AlternateTitleEntity {
        let entity = Self(context: ctx)
        entity.title = title
        entity.unique = "\(mangaId)@@@\(title)"
        
        return entity
    }
    
    static func from(ctx: NSManagedObjectContext, titles: [String], manga: MangaEntity) -> Set<AlternateTitleEntity> {
        var entities = Set<AlternateTitleEntity>()
        for title in titles {
            let entity = AlternateTitleEntity.from(ctx: ctx, title: title, mangaId: manga.mangaId)
            entity.manga = manga
            entities.insert(entity)
        }
        
        return entities
    }
}
