//
//  ScraperWithMangaInCollection.swift
//  Dokusho
//
//  Created by Stef on 23/12/2021.
//

import Combine
import GRDBQuery
import GRDB
import SwiftUI

struct ScraperWithMangaCount: Codable, FetchableRecord, Identifiable {
    var id: UUID { scraper.id }
    var scraper: Scraper
    var mangaCount: Int
}

struct ScraperWithMangaInCollection: Queryable {
    static var defaultValue: [ScraperWithMangaCount] { [] }
    
    func publisher(in database: AppDatabase) -> AnyPublisher<[ScraperWithMangaCount], Error> {
        ValueObservation
            .tracking(fetchValue(_:))
            .publisher(in: database.database, scheduling: .immediate)
            .eraseToAnyPublisher()
    }
    
    func fetchValue(_ db: Database) throws -> [ScraperWithMangaCount] {
        let request = Scraper
            .select(Scraper.databaseSelection + [count(SQL(sql: "DISTINCT manga.rowid")).forKey("mangaCount")])
            .joining(required: Scraper.mangas)
            .group(Scraper.Columns.id)
            .orderByPosition()

        return try ScraperWithMangaCount.fetchAll(db, request)
    }
}

