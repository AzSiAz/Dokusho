//
//  GenreEntity.swift
//  GenreEntity
//
//  Created by Stephan Deumier on 18/08/2021.
//

import Foundation
import CoreData

extension GenreEntity {
    convenience init(ctx: NSManagedObjectContext, name: String) {
        self.init(entity: Self.entity(), insertInto: ctx)
        
        self.name = name
    }
}
