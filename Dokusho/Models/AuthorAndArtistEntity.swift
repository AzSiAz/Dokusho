//
//  AuthorAndArtistEntity.swift
//  AuthorAndArtistEntity
//
//  Created by Stephan Deumier on 18/08/2021.
//

import Foundation
import CoreData

enum AuthorAndArtistType: String, CaseIterable {
    case author = "Author"
    case artist = "Artist"
    case unknown = "Unknown"
}

extension AuthorAndArtistEntity {
    convenience init(ctx: NSManagedObjectContext, name: String, type: AuthorAndArtistType) {
        self.init(entity: Self.entity(), insertInto: ctx)
        
        self.name = name
        self.typeRaw = type.rawValue
    }
}
