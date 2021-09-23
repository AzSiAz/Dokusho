//
//  AuthorAndArtistEntity.swift
//  AuthorAndArtistEntity
//
//  Created by Stephan Deumier on 18/08/2021.
//

import Foundation
import CoreData

enum AuthorAndArtistType: String, CaseIterable {
    case author = "Author"
    case artist = "Artist"
    case unknown = "Unknown"
}

extension AuthorAndArtistEntity {
    convenience init(ctx: NSManagedObjectContext, name: String, type: AuthorAndArtistType) {
        self.init(entity: Self.entity(), insertInto: ctx)
        
        self.name = name
        self.typeRaw = type.rawValue
    }
    
    static func fetchOne(ctx: NSManagedObjectContext, name: String, type: AuthorAndArtistType) -> AuthorAndArtistEntity? {
        let req = Self.fetchRequest()
        
        req.fetchLimit = 1
        req.predicate = Self.byNameAndTypePredicate(name: name, type: type)
        
        return try? ctx.fetch(req).first
    }
    
    static func fromSourceSource(ctx: NSManagedObjectContext, name: String, type: AuthorAndArtistType, manga: MangaEntity) -> AuthorAndArtistEntity {
        let d: AuthorAndArtistEntity
        if let found = Self.fetchOne(ctx: ctx, name: name, type: type) {
            d = found
        } else {
            d = AuthorAndArtistEntity(ctx: ctx, name: name, type: type)
        }
        
        d.addToMangas(manga)
        
        return d
    }
    
    static func byNameAndTypePredicate(name: String, type: AuthorAndArtistType) -> NSPredicate {
        return NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(format: "%K CONTAINS[cd] %@", #keyPath(AuthorAndArtistEntity.name), name),
            NSPredicate(format: "%K = %@", #keyPath(AuthorAndArtistEntity.typeRaw), type.rawValue)
        ])
    }
}
