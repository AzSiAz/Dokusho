//
//  OneMangaCollectionRequest.swift
//  Dokusho
//
//  Created by Stef on 22/12/2021.
//

import GRDBQuery
import GRDB
import Foundation

public struct OneMangaCollectionRequest: Queryable {
    public static var defaultValue: MangaCollection? { nil }
    
    public var collectionId: UUID
    
    public init(collectionId: UUID) {
        self.collectionId = collectionId
    }
    
    public func publisher(in database: AppDatabase) -> DatabasePublishers.Value<MangaCollection?> {
        ValueObservation
            .tracking(MangaCollection.filter(id: collectionId).fetchOne(_:))
            .publisher(in: database.database, scheduling: .immediate)
    }
}

