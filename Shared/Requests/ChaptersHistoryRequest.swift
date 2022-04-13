//
//  ChaptersHistoryRequest.swift
//  Dokusho
//
//  Created by Stef on 23/12/2021.
//

import Combine
import GRDB
import GRDBQuery

enum ChapterStatusHistory: String {
    case all = "Update", read = "Read"
}

struct ChaptersHistory: Decodable, FetchableRecord, Identifiable {
    var id: String { chapter.id }
    var chapter: MangaChapter
    var manga: PartialManga
    var scraper: Scraper
}


struct ChaptersHistoryRequest: Queryable {
    var filter: ChapterStatusHistory = .all
    var searchTerm: String
    
    static var defaultValue: [ChaptersHistory] { [] }
    
    func publisher(in database: AppDatabase) -> AnyPublisher<[ChaptersHistory], Error> {
        ValueObservation
            .tracking(fetchValue(_:))
            .publisher(in: database.database, scheduling: .immediate)
            .eraseToAnyPublisher()
    }
    
    func fetchValue(_ db: Database) throws -> [ChaptersHistory] {
        var request = MangaChapter
            .all()
            .including(required: MangaChapter.manga)
            .including(required: MangaChapter.scraper)
            .filter(filter)
        
        if !searchTerm.isEmpty { request = request.including(required: MangaChapter.manga.filterByName(searchTerm)) }

        return try ChaptersHistory.fetchAll(db, request)
    }
}
