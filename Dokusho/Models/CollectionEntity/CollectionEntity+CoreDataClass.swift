//
//  CollectionEntity+CoreDataClass.swift
//  CollectionEntity
//
//  Created by Stephan Deumier on 04/09/2021.
//
//

import Foundation
import CoreData

@objc(CollectionEntity)
public class CollectionEntity: NSManagedObject {}

extension CollectionEntity {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<CollectionEntity> {
        return NSFetchRequest<CollectionEntity>(entityName: "CollectionEntity")
    }
    
    @NSManaged public var filterRaw: String?
    @NSManaged public var name: String?
    @NSManaged public var position: Int16
    @NSManaged public var uuid: UUID?
    @NSManaged public var mangas: Set<MangaEntity>?
    
}

    // MARK: Generated accessors for mangas
extension CollectionEntity {
    
    @objc(addMangasObject:)
    @NSManaged public func addToMangas(_ value: MangaEntity)
    
    @objc(removeMangasObject:)
    @NSManaged public func removeFromMangas(_ value: MangaEntity)
    
    @objc(addMangas:)
    @NSManaged public func addToMangas(_ values: Set<MangaEntity>)
    
    @objc(removeMangas:)
    @NSManaged public func removeFromMangas(_ values: Set<MangaEntity>)
    
}

extension CollectionEntity : Identifiable {}
