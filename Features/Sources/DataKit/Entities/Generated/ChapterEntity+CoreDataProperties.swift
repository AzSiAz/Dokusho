//
//  ChapterEntity+CoreDataProperties.swift
//  Dokusho
//
//  Created by Stephan Deumier on 30/06/2022.
//
//

import Foundation
import CoreData


extension ChapterEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ChapterEntity> {
        return NSFetchRequest<ChapterEntity>(entityName: "ChapterEntity")
    }

    @NSManaged public var chapterId: String
    @NSManaged public var title: String
    @NSManaged public var dateSourceUpload: Date
    @NSManaged public var position: Int16
    @NSManaged public var readAt: Date
    @NSManaged public var status: Int16
    @NSManaged public var externalUrl: URL
    @NSManaged public var manga: MangaEntity
}

extension ChapterEntity : Identifiable {}
