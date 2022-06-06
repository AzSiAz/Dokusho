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

public struct GenreWithMangaCount: Decodable, FetchableRecord, Identifiable {
    public var id: String { genre }
    public var genre: String
    public var mangaCount: Int
}

public struct DistinctMangaGenreRequest: Queryable {
    public static var defaultValue: [GenreWithMangaCount] { [] }
    
    public init() {}
    
    public func publisher(in database: AppDatabase) -> AnyPublisher<[GenreWithMangaCount], Error> {
        ValueObservation
            .tracking(fetchValue(_:))
            .publisher(in: database.database, scheduling: .immediate)
            .eraseToAnyPublisher()
    }
    
    public func fetchValue(_ db: Database) throws -> [GenreWithMangaCount] {
        return try GenreWithMangaCount.fetchAll(db, sql: """
            SELECT DISTINCT(t2.value) as genre, COUNT(DISTINCT(t1.rowid)) as mangaCount
            FROM manga AS t1
            JOIN json_each((SELECT genres FROM manga WHERE id = t1.id)) AS t2
            WHERE t1."mangaCollectionId" IS NOT NULL
            GROUP BY t2.value;
        """)
    }
}
