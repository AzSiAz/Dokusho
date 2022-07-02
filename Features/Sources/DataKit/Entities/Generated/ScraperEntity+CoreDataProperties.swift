//
//  ScraperEntity+CoreDataProperties.swift
//  Dokusho
//
//  Created by Stephan Deumier on 30/06/2022.
//
//

import Foundation
import CoreData


extension ScraperEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ScraperEntity> {
        return NSFetchRequest<ScraperEntity>(entityName: "ScraperEntity")
    }

    @NSManaged public var id: UUID
    @NSManaged public var name: String
    @NSManaged public var position: Int16
    @NSManaged public var isFavorite: Bool
    @NSManaged public var isActive: Bool
    @NSManaged public var mangas: NSSet

}

// MARK: Generated accessors for mangas
extension ScraperEntity {

    @objc(addMangasObject:)
    @NSManaged public func addToMangas(_ value: MangaEntity)

    @objc(removeMangasObject:)
    @NSManaged public func removeFromMangas(_ value: MangaEntity)

    @objc(addMangas:)
    @NSManaged public func addToMangas(_ values: Set<MangaEntity>)

    @objc(removeMangas:)
    @NSManaged public func removeFromMangas(_ values: Set<MangaEntity>)

}

extension ScraperEntity : Identifiable {}
