//
//  AlternateTitlesEntity.swift
//  AlternateTitlesEntity
//
//  Created by Stephan Deumier on 18/08/2021.
//

import Foundation
import CoreData

extension AlternateTitlesEntity {
    convenience init(ctx: NSManagedObjectContext, title: String, sourceId: Int) {
        self.init(entity: Self.entity(), insertInto: ctx)
        
        self.title = title
        self.key = "\(sourceId)%%\(title)"
    }
}


