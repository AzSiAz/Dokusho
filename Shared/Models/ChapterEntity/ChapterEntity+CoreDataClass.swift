//
//  ChapterEntity+CoreDataClass.swift
//  ChapterEntity
//
//  Created by Stephan Deumier on 04/09/2021.
//
//

import Foundation
import CoreData

enum ChapterStatus: String, CaseIterable {
    case unread = "Unread"
    case read = "Read"
}


@objc(ChapterEntity)
public class ChapterEntity: NSManagedObject {}

extension ChapterEntity {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<ChapterEntity> {
        return NSFetchRequest<ChapterEntity>(entityName: "ChapterEntity")
    }
    
    @NSManaged public var chapterId: String?
    @NSManaged public var dateSourceUpload: Date?
    @NSManaged public var key: String?
    @NSManaged public var position: Int32
    @NSManaged public var readAt: Date?
    @NSManaged public var statusRaw: String?
    @NSManaged public var title: String?
    @NSManaged public var manga: MangaEntity?
    
}

extension ChapterEntity : Identifiable {}

extension ChapterEntity {
    var status: ChapterStatus {
        get {
            return .init(rawValue: self.statusRaw ?? "") ?? .unread
        }
        
        set {
            self.statusRaw = newValue.rawValue
        }
    }
}
