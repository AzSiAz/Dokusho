//
//  SourceEntity.swift
//  SourceEntity
//
//  Created by Stephan Deumier on 17/08/2021.
//

import Foundation
import MangaScraper
import CoreData

extension SourceEntity {
    convenience init(ctx: NSManagedObjectContext, source: Source) {
        self.init(entity: Self.entity(), insertInto: ctx)
        
        self.sourceId = source.id
    }
    
    func getSource() throws -> Source {
        guard let source = MangaScraperService.shared.getSource(sourceId: self.sourceId!) else {
            throw "Source not found, it's not normal"
        }

        return source
    }
    
    static func createFromSource(ctx: NSManagedObjectContext, source: Source) -> SourceEntity {
        let entity: SourceEntity
        if let found = SourceEntity.fetchOne(sourceId: source.id, ctx: ctx) {
            entity = found
        } else {
            entity = SourceEntity(ctx: ctx, source: source)
        }
        
        return entity
    }
}

extension SourceEntity {
    static func fetchMany(ctx: NSManagedObjectContext) -> [SourceEntity] {
        guard let res = try? ctx.fetch(SourceEntity.sourceFetchRequest) else { return [] }
        return res
    }
    
    static func fetchOne(sourceId: UUID, ctx: NSManagedObjectContext) -> SourceEntity? {
        let req = Self.fetchRequest()
        
        req.predicate = NSPredicate(format: "%K = %@", #keyPath(SourceEntity.sourceId), sourceId as NSUUID)
        req.fetchLimit = 1

        return try? ctx.fetch(req).first
    }
}

extension SourceEntity {
    static var sourceFetchRequest: NSFetchRequest<SourceEntity> {
        let request = SourceEntity.fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \SourceEntity.position, ascending: true),
        ]
        
        return request
    }
    
    static var onlyFavoriteOrActive: NSPredicate {
        return NSCompoundPredicate(orPredicateWithSubpredicates: [
            favoritePredicate,
            activePredicate
        ])
    }
    
    static var onlyFavoriteAndActive: NSPredicate {
        return NSCompoundPredicate(andPredicateWithSubpredicates: [
            favoritePredicate,
            activePredicate
        ])
    }
    
    static var NotFavoriteOrActive: NSPredicate {
        return NSCompoundPredicate(orPredicateWithSubpredicates: [
            NSCompoundPredicate(andPredicateWithSubpredicates: [
                NSCompoundPredicate(notPredicateWithSubpredicate: activePredicate),
                favoritePredicate
            ]),
            NSCompoundPredicate(notPredicateWithSubpredicate: onlyFavoriteOrActive),
        ])
    }
    
    static var onlyActiveAndNotFavorite: NSPredicate {
        return NSCompoundPredicate(andPredicateWithSubpredicates: [
            activePredicate,
            NSCompoundPredicate(notPredicateWithSubpredicate: favoritePredicate)
        ])
    }
    
    static var favoritePredicate: NSPredicate {
        return NSPredicate(format: "%K = %d",  #keyPath(SourceEntity.favorite), true)
    }
    
    static var activePredicate: NSPredicate {
        return NSPredicate(format: "%K = %d", #keyPath(SourceEntity.active), true)
    }
    
    static var positionOrder: SortDescriptor<SourceEntity> {
        return SortDescriptor<SourceEntity>(\.position, order: .forward)
    }
}
