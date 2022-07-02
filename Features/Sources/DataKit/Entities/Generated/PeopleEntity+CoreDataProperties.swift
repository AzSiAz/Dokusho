//
//  PeopleEntity+CoreDataProperties.swift
//  Dokusho
//
//  Created by Stephan Deumier on 30/06/2022.
//
//

import Foundation
import CoreData


extension PeopleEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PeopleEntity> {
        return NSFetchRequest<PeopleEntity>(entityName: "PeopleEntity")
    }

    @NSManaged public var isAuthor: Bool
    @NSManaged public var name: String
    @NSManaged public var isArtist: Bool
    @NSManaged public var unique: String
    @NSManaged public var manga: MangaEntity

}

extension PeopleEntity : Identifiable {}
