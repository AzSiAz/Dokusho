////
////  ChaptersHistoryRequest.swift
////  Dokusho
////
////  Created by Stef on 23/12/2021.
////
//
//import Combine
//import GRDB
//import GRDBQuery
//
//public struct ChaptersHistory: Decodable, FetchableRecord, Identifiable {
//    public var id: String { chapter.id }
//    public var chapter: MangaChapterDB
//    public var manga: PartialManga
//    public var scraper: ScraperDB
//}
//
//public struct ChaptersHistoryRequest: Queryable {
//    public var filter: ChapterStatusHistory = .all
//    public var searchTerm: String
//    
//    public init(filter: ChapterStatusHistory, searchTerm: String) {
//        self.filter = filter
//        self.searchTerm = searchTerm
//    }
//    
//    public static var defaultValue: [ChaptersHistory] { [] }
//    
//    public func publisher(in database: some DatabaseReader) -> AnyPublisher<[ChaptersHistory], Error> {
//        ValueObservation
//            .tracking(fetchValue(_:))
//            .publisher(in: database, scheduling: .immediate)
//            .eraseToAnyPublisher()
//    }
//    
//    public func fetchValue(_ db: Database) throws -> [ChaptersHistory] {
//        var request = MangaChapterDB
//            .all()
//            .including(required: MangaChapterDB.manga)
//            .including(required: MangaChapterDB.scraper)
//            .filter(filter)
//        
//        if !searchTerm.isEmpty { request = request.including(required: MangaChapterDB.manga.filterByName(searchTerm)) }
//
//        return try ChaptersHistory.fetchAll(db, request)
//    }
//}
