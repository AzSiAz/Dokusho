//
//  SourceEntity+CoreDataClass.swift
//  SourceEntity
//
//  Created by Stephan Deumier on 04/09/2021.
//
//

import Foundation
import CoreData

@objc(SourceEntity)
public class SourceEntity: NSManagedObject {}

extension SourceEntity {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<SourceEntity> {
        return NSFetchRequest<SourceEntity>(entityName: "SourceEntity")
    }
    
    @NSManaged public var active: Bool
    @NSManaged public var favorite: Bool
    @NSManaged public var icon: URL?
    @NSManaged public var language: String?
    @NSManaged public var name: String?
    @NSManaged public var position: Int16
    @NSManaged public var sourceId: Int32
    @NSManaged public var mangas: Set<MangaEntity>?
    
}

    // MARK: Generated accessors for mangas
extension SourceEntity {
    
    @objc(addMangasObject:)
    @NSManaged public func addToMangas(_ value: MangaEntity)
    
    @objc(removeMangasObject:)
    @NSManaged public func removeFromMangas(_ value: MangaEntity)
    
    @objc(addMangas:)
    @NSManaged public func addToMangas(_ values: Set<MangaEntity>)
    
    @objc(removeMangas:)
    @NSManaged public func removeFromMangas(_ values: Set<MangaEntity>)
    
}

extension SourceEntity : Identifiable {}
