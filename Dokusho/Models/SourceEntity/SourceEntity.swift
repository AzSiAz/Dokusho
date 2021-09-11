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
        
        self.sourceId = Int32(source.id)
        self.name = source.name
        self.language = source.lang.rawValue
        self.icon = URL(string: source.icon)
    }
    
    func getSource() throws -> Source {
        guard let source = MangaScraperService.shared.getSource(sourceId: Int(self.sourceId)) else {
            throw "Source not found, it's not normal"
        }
        
        return source
    }
}

extension SourceEntity {
    static func importAtAppStart(sources: [Source]) async {
        let ctx = PersistenceController.shared.container.newBackgroundContext()
        
        await ctx.perform {
            sources.forEach { src in
                ctx.insert(SourceEntity(ctx: ctx, source: src))
            }
            
            try? ctx.save()
        }
    }
    
    static func fetchOne(sourceId: Int, ctx: NSManagedObjectContext) -> SourceEntity? {
        let req = Self.fetchRequest()
        
        req.predicate = NSPredicate(format: "%K = %i", #keyPath(SourceEntity.sourceId), sourceId)
        req.fetchLimit = 1

        let res = try? ctx.fetch(req)
        return res?.first
    }
}

extension SourceEntity {
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
    
    static var nameOrder: SortDescriptor<SourceEntity> {
        return SortDescriptor<SourceEntity>(\.name, order: .forward)
    }
}
