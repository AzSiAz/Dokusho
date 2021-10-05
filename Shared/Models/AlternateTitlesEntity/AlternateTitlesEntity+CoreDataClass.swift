//
//  AlternateTitlesEntity+CoreDataClass.swift
//  AlternateTitlesEntity
//
//  Created by Stephan Deumier on 04/09/2021.
//
//

import Foundation
import CoreData

@objc(AlternateTitlesEntity)
public class AlternateTitlesEntity: NSManagedObject {}

extension AlternateTitlesEntity {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<AlternateTitlesEntity> {
        return NSFetchRequest<AlternateTitlesEntity>(entityName: "AlternateTitlesEntity")
    }
    
    @NSManaged public var key: String?
    @NSManaged public var title: String?
    @NSManaged public var manga: MangaEntity?
    
    static func generateKey(title: String, sourceId: UUID) -> String {
        return "\(sourceId.uuidString)%%\(title)"
    }
    
}

extension AlternateTitlesEntity : Identifiable {}
