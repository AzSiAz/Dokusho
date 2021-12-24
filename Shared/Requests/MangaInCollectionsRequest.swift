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

struct MangaInCollection: Decodable, FetchableRecord {
    var mangaId: String
    var collectionName: String
}

struct MangaInCollectionsRequest: Queryable {
    static var defaultValue: [MangaInCollection] { [] }
    
    let srcId: UUID
    
    func publisher(in database: AppDatabase) -> AnyPublisher<[MangaInCollection], Error> {
        ValueObservation
            .tracking(fetchValue(_:))
            .publisher(in: database.database, scheduling: .immediate)
            .eraseToAnyPublisher()
    }
    
    func fetchValue(_ db: Database) throws -> [MangaInCollection] {
        return try Manga
            .select([Manga.Columns.mangaId])
            .annotated(withRequired: Manga.mangaCollection.select(MangaCollection.Columns.name.forKey("collectionName")))
            .whereSource(srcId)
            .asRequest(of: MangaInCollection.self)
            .fetchAll(db)
    }
}
