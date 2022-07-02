//
//  GenreEntity+CoreDataProperties.swift
//  Dokusho
//
//  Created by Stephan Deumier on 30/06/2022.
//
//

import Foundation
import CoreData


extension GenreEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<GenreEntity> {
        return NSFetchRequest<GenreEntity>(entityName: "GenreEntity")
    }

    @NSManaged public var name: String
    @NSManaged public var unique: String
    @NSManaged public var mangas: MangaEntity

}

extension GenreEntity : Identifiable {}
