//
//  MangaCollection.swift
//  MangaCollection
//
//  Created by Stephan Deumier on 25/08/2021.
//

import Foundation
import CoreData

extension CollectionEntity {
    convenience init(ctx: NSManagedObjectContext, name: String, position: Int, uuid: UUID = UUID()) {
        self.init(entity: Self.entity(), insertInto: ctx)
        
        self.uuid = uuid
        self.name = name
        self.position = Int16(position)
    }
    
    func updateFilter(newFilter: CollectionEntityFilter) {
        self.filterRaw = newFilter.rawValue
    }
    
    func updatePosition(newPosition: Int) {
        self.position = Int16(newPosition)
    }
    
    func getName() -> String {
        return self.name ?? "No title for collection"
    }
}

extension CollectionEntity {
    static func fromBackup(info: CollectionBackup, ctx: NSManagedObjectContext) -> CollectionEntity {
        if let id = info.id {
            let collection = Self.fetchOne(collectionId: id, ctx: ctx)
            if let collection = collection {
                return collection
            }
        }
        
        return CollectionEntity(ctx: ctx, name: info.name, position: info.position)
    }
    
    static func fetchOne(collectionId: UUID, ctx: NSManagedObjectContext) -> CollectionEntity? {
        let req = CollectionEntity.fetchRequest()
        req.fetchLimit = 1
        req.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(format: "%K = %@", #keyPath(CollectionEntity.uuid), collectionId.uuidString),
        ])
        let res = try? ctx.fetch(req)
        
        return res?.first
    }
    
    static func fetchMany(ctx: NSManagedObjectContext) -> [CollectionEntity] {
        let results = try! ctx.fetch(CollectionEntity.collectionFetchRequest)
        
        return results.isEmpty ? [] : results
    }
    
    static var collectionFetchRequest: NSFetchRequest<CollectionEntity> {
        let request = CollectionEntity.fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \CollectionEntity.position, ascending: true),
        ]
        
        return request
    }
}

extension CollectionEntity {
    static var positionOrder: SortDescriptor<CollectionEntity> { SortDescriptor<CollectionEntity>(\.position, order: .forward) }
}
