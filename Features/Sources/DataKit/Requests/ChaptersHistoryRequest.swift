//
//  ChaptersHistoryRequest.swift
//  Dokusho
//
//  Created by Stef on 23/12/2021.
//

import Combine
import GRDB
import GRDBQuery

public struct ChaptersHistory: Decodable, FetchableRecord, Identifiable {
    public var id: String { chapter.id }
    public var chapter: MangaChapter
    public var manga: PartialManga
    public var scraper: Scraper
}


public struct ChaptersHistoryRequest: Queryable {
    public var filter: ChapterStatusHistory = .all
    public var searchTerm: String
    
    public init(filter: ChapterStatusHistory, searchTerm: String) {
        self.filter = filter
        self.searchTerm = searchTerm
    }
    
    public static var defaultValue: [ChaptersHistory] { [] }
    
    public func publisher(in database: AppDatabase) -> AnyPublisher<[ChaptersHistory], Error> {
        ValueObservation
            .tracking(fetchValue(_:))
            .publisher(in: database.database, scheduling: .immediate)
            .eraseToAnyPublisher()
    }
    
    public func fetchValue(_ db: Database) throws -> [ChaptersHistory] {
        var request = MangaChapter
            .all()
            .including(required: MangaChapter.manga)
            .including(required: MangaChapter.scraper)
            .filter(filter)
        
        if !searchTerm.isEmpty { request = request.including(required: MangaChapter.manga.filterByName(searchTerm)) }

        return try ChaptersHistory.fetchAll(db, request)
    }
}
