//
//  DetailedMangaCollectionRequest.swift
//  Dokusho
//
//  Created by Stef on 22/12/2021
//

import Combine
import GRDBQuery
import GRDB
import SwiftUI

struct DetailedMangaCollection: Decodable, FetchableRecord, Identifiable {
    var mangaCollection: MangaCollection
    var mangaCount: Int
    var id: UUID { mangaCollection.id }
}

struct DetailedMangaCollectionRequest: Queryable {
    static var defaultValue: [DetailedMangaCollection] { [] }
    
    func publisher(in database: AppDatabase) -> AnyPublisher<[DetailedMangaCollection], Error> {
        ValueObservation
            .tracking(fetchValue(_:))
            .publisher(in: database.database, scheduling: .immediate)
            .eraseToAnyPublisher()
    }
    
    func fetchValue(_ db: Database) throws -> [DetailedMangaCollection] {
        let request = MangaCollection
            .annotated(with: MangaCollection.mangas.count)
            .group(MangaCollection.Columns.id)
            .orderByPosition()

        return try DetailedMangaCollection
            .fetchAll(db, request)
    }
}

