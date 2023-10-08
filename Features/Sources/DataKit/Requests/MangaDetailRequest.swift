////
////  OneMangaCollectionRequest.swift
////  Dokusho
////
////  Created by Stef on 20/04/2022.
////
//
//import GRDBQuery
//import GRDB
//import Foundation
//
//public struct MangaDetailRequest: Queryable {
//    public static var defaultValue: MangaWithDetail? { nil }
//
//    public var mangaId: String
//    public var scraper: ScraperDB
//    
//    public init(mangaId: String, scraper: ScraperDB) {
//        self.mangaId = mangaId
//        self.scraper = scraper
//    }
//
//    public func publisher(in database: AppDatabase) -> DatabasePublishers.Value<MangaWithDetail?> {
//        ValueObservation
//            .tracking(fetchValue(_:))
//            .publisher(in: database.database, scheduling: .immediate)
//    }
//    
//    public func fetchValue(_ db: Database) throws -> MangaWithDetail? {
//        guard let manga = try MangaDB.fetchMangaWithDetail(for: mangaId, in: scraper.id, db) else {
//            Task {
//                guard let source = scraper.asSource() else { throw "Source Not found" }
//                let sourceManga = try await source.fetchMangaDetail(id: mangaId)
//                
//                try _ = await AppDatabase.shared.database.write { db in
//                    try MangaDB.updateFromSource(db: db, scraper: self.scraper, data: sourceManga)
//                }
//            }
//            
//            return nil
//        }
//        
//        return manga
//    }
//}
//
