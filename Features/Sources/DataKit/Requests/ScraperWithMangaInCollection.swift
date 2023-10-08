////
////  ScraperWithMangaInCollection.swift
////  Dokusho
////
////  Created by Stef on 23/12/2021.
////
//
//import Combine
//import GRDBQuery
//import GRDB
//import SwiftUI
//
//public struct ScraperWithMangaCount: Codable, FetchableRecord, Identifiable {
//    public var id: UUID { scraper.id }
//    public var scraper: ScraperDB
//    public var mangaCount: Int
//}
//
//public struct ScraperWithMangaInCollection: Queryable {
//    public static var defaultValue: [ScraperWithMangaCount] { [] }
//    
//    public init() {}
//    
//    public func publisher(in database: AppDatabase) -> AnyPublisher<[ScraperWithMangaCount], Error> {
//        ValueObservation
//            .tracking(fetchValue(_:))
//            .publisher(in: database.database, scheduling: .immediate)
//            .eraseToAnyPublisher()
//    }
//    
//    public func fetchValue(_ db: Database) throws -> [ScraperWithMangaCount] {
//        let request = ScraperDB
//            .select(ScraperDB.databaseSelection + [count(SQL(sql: "DISTINCT manga.rowid")).forKey("mangaCount")])
//            .joining(required: ScraperDB.mangas.isInCollection())
//            .group(ScraperDB.Columns.id)
//            .orderByPosition()
//
//        return try ScraperWithMangaCount.fetchAll(db, request)
//    }
//}
