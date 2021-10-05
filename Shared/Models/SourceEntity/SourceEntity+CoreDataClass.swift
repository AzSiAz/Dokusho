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
    @NSManaged public var position: Int16
    @NSManaged public var sourceId: UUID
}

extension SourceEntity : Identifiable {}
