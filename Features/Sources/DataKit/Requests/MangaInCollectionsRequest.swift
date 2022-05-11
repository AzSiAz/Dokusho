//
//  MangaInCollectionsRequest.swift
//  Dokusho
//
//  Created by Stef on 22/12/2021.
//

import Combine
import GRDBQuery
import GRDB
import SwiftUI

public struct MangaInCollection: Decodable, FetchableRecord {
    public var mangaId: String
    public var collectionName: String
}

public struct MangaInCollectionsRequest: Queryable {
    public static var defaultValue: [MangaInCollection] { [] }
    
    public let srcId: UUID
    
    public init(srcId: UUID) {
        self.srcId = srcId
    }
    
    public func publisher(in database: AppDatabase) -> AnyPublisher<[MangaInCollection], Error> {
        ValueObservation
            .tracking(fetchValue(_:))
            .publisher(in: database.database, scheduling: .immediate)
            .eraseToAnyPublisher()
    }
    
    public func fetchValue(_ db: Database) throws -> [MangaInCollection] {
        return try Manga
            .select([Manga.Columns.mangaId])
            .annotated(withRequired: Manga.mangaCollection.select(MangaCollection.Columns.name.forKey("collectionName")))
            .whereSource(srcId)
            .asRequest(of: MangaInCollection.self)
            .fetchAll(db)
    }
}
