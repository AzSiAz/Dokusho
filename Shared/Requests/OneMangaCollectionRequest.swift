//
//  OneMangaCollectionRequest.swift
//  Dokusho
//
//  Created by Stef on 22/12/2021.
//

import GRDBQuery
import GRDB
import Foundation

struct OneMangaCollectionRequest: Queryable {
    static var defaultValue: MangaCollection? { nil }
    
    var collectionId: UUID
    
    func publisher(in database: AppDatabase) -> DatabasePublishers.Value<MangaCollection?> {
        ValueObservation
            .tracking(MangaCollection.filter(id: collectionId).fetchOne(_:))
            .publisher(in: database.database, scheduling: .immediate)
    }
}

