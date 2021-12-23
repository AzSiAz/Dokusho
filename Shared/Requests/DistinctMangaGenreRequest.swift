//
//  DistinctMangaGenreRequest.swift
//  Dokusho
//
//  Created by Stef on 23/12/2021.
//

import Combine
import GRDBQuery
import GRDB
import SwiftUI

struct GenreWithMangaCount: Decodable, FetchableRecord, Identifiable {
    var id: String { genre }
    var genre: String
    var mangaCount: Int
}

struct DistinctMangaGenreRequest: Queryable {
    static var defaultValue: [GenreWithMangaCount] { [] }
    
    func publisher(in database: AppDatabase) -> AnyPublisher<[GenreWithMangaCount], Error> {
        ValueObservation
            .tracking(fetchValue(_:))
            .publisher(in: AppDatabase.shared.database, scheduling: .immediate)
            .eraseToAnyPublisher()
    }
    
    func fetchValue(_ db: Database) throws -> [GenreWithMangaCount] {
        return try GenreWithMangaCount.fetchAll(db, sql: """
            SELECT DISTINCT(t2.value) as genre, COUNT(DISTINCT(t1.rowid)) as mangaCount
            FROM manga AS t1
            JOIN json_each((SELECT genres FROM manga WHERE id = t1.id)) AS t2
            GROUP BY t2.value;
        """)
    }
}
