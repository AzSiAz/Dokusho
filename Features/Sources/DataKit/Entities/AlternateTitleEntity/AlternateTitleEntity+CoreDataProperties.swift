//
//  AlternateTitleEntity+CoreDataProperties.swift
//  Dokusho
//
//  Created by Stephan Deumier on 30/06/2022.
//
//

import Foundation
import CoreData


extension AlternateTitleEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<AlternateTitleEntity> {
        return NSFetchRequest<AlternateTitleEntity>(entityName: "AlternateTitleEntity")
    }

    @NSManaged public var title: String
    @NSManaged public var unique: String
    @NSManaged public var manga: MangaEntity

}

extension AlternateTitleEntity : Identifiable {}
