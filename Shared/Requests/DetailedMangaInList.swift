//
//  DetailedMangaInCollectionsRequest.swift
//  Dokusho
//
//  Created by Stef on 22/12/2021.
//

import GRDB
import Combine
import Foundation
import GRDBQuery

struct DetailedMangaInList: Identifiable, FetchableRecord, Decodable {
    var id: UUID { manga.id }
    var manga: PartialManga
    var scraper: Scraper
    var unreadChapterCount: Int
    var readChapterCount: Int
    var chapterCount: Int
    var lastUpdate: Date?
}

struct DetailedMangaInListRequest: Queryable {
    static var defaultValue: [DetailedMangaInList] { [] }

    var searchTerm: String = ""
    var genre: String?
    var scraper: Scraper?
    var collection: MangaCollection?
    var collectionFilter: MangaCollectionFilter?
    var collectionOrder: MangaCollectionOrder?
    
    func publisher(in database: AppDatabase) -> AnyPublisher<[DetailedMangaInList], Error> {
        ValueObservation
            .tracking(fetchValue(_:))
            .publisher(in: database.database, scheduling: .immediate)
            .eraseToAnyPublisher()
    }
    
    func fetchValue(_ db: Database) throws -> [DetailedMangaInList] {
        let unreadChapterCount = "DISTINCT \"mangaChapter\".\"rowid\") FILTER (WHERE mangaChapter.status = 'unread'"
        let readChapterCount = "DISTINCT \"mangaChapter\".\"rowid\") FILTER (WHERE mangaChapter.status = 'read'"
        let chapterCount = "DISTINCT \"mangaChapter\".\"rowid\""

        var request = Manga
            .select([
                Manga.Columns.id,
                Manga.Columns.mangaId,
                Manga.Columns.title,
                Manga.Columns.scraperId,
                Manga.Columns.cover,
                count(SQL(sql: unreadChapterCount)).forKey("unreadChapterCount"),
                count(SQL(sql: readChapterCount)).forKey("readChapterCount"),
                count(SQL(sql: chapterCount)).forKey("chapterCount"),
                max(SQL(sql: "\"mangaChapter\".\"dateSourceUpload\"")).forKey("lastUpdate")
            ])
            .joining(optional: Manga.chapters)
            .including(required: Manga.scraper)
            .group(Manga.Columns.id)
        
        if let collection = collection {
            request = request.forCollectionId(collection.id)

            if !searchTerm.isEmpty { request = request.filterByName(searchTerm) }

            if let collectionFilter = collectionFilter {
                switch collectionFilter {
                case .all: break
                case .onlyUnReadChapter: request = request.having(sql: "unreadChapterCount > 0")
                case .completed: request = request.forMangaStatus(.complete)
                }

            }
            
            if let collectionOrder = collectionOrder {
                switch collectionOrder.field {
                case .unreadChapters: request = request.order(sql: "unreadChapterCount \(collectionOrder.direction)")
                case .title: request = request.orderByTitle(direction: collectionOrder.direction)
                case .lastUpdate: request = request.order(sql: "mangaChapter.dateSourceUpload \(collectionOrder.direction)")
                case .chapterCount: request = request.order(sql: "chapterCount \(collectionOrder.direction)")
                }
            }
        } else if let genre = genre {
            request = request.orderByTitle().filterByGenre(genre).isInCollection()
        } else if let scraper = scraper {
            request = request.orderByTitle().whereSource(scraper.id).isInCollection()
        }
        
        return try DetailedMangaInList.fetchAll(db, request)
    }
}


struct DetailedMangaInCollectionRequest: Queryable {
    static var defaultValue: [DetailedMangaInList] { [] }

    var searchTerm: String = ""
    var collection: MangaCollection
    var collectionFilter: MangaCollectionFilter
    var collectionOrder: MangaCollectionOrder
    
    init(collection: MangaCollection) {
        self.collection = collection
        self.collectionFilter = collection.filter
        self.collectionOrder = collection.order
    }
    
    func publisher(in database: AppDatabase) -> AnyPublisher<[DetailedMangaInList], Error> {
        ValueObservation
            .tracking(fetchValue(_:))
            .publisher(in: database.database, scheduling: .immediate)
            .eraseToAnyPublisher()
    }
    
    func fetchValue(_ db: Database) throws -> [DetailedMangaInList] {
        let unreadChapterCount = "DISTINCT \"mangaChapter\".\"rowid\") FILTER (WHERE mangaChapter.status = 'unread'"
        let readChapterCount = "DISTINCT \"mangaChapter\".\"rowid\") FILTER (WHERE mangaChapter.status = 'read'"
        let chapterCount = "DISTINCT \"mangaChapter\".\"rowid\""

        var request = Manga
            .select([
                Manga.Columns.id,
                Manga.Columns.mangaId,
                Manga.Columns.title,
                Manga.Columns.scraperId,
                Manga.Columns.cover,
                count(SQL(sql: unreadChapterCount)).forKey("unreadChapterCount"),
                count(SQL(sql: readChapterCount)).forKey("readChapterCount"),
                count(SQL(sql: chapterCount)).forKey("chapterCount"),
                max(SQL(sql: "\"mangaChapter\".\"dateSourceUpload\"")).forKey("lastUpdate")
            ])
            .joining(optional: Manga.chapters)
            .including(required: Manga.scraper)
            .group(Manga.Columns.id)
        
        request = request.forCollectionId(collection.id)

        if !searchTerm.isEmpty { request = request.filterByName(searchTerm) }

        switch collectionFilter {
        case .all: break
        case .onlyUnReadChapter: request = request.having(sql: "unreadChapterCount > 0")
        case .completed: request = request.forMangaStatus(.complete)
        }

        switch collectionOrder.field {
        case .unreadChapters: request = request.order(sql: "unreadChapterCount \(collectionOrder.direction)")
        case .title: request = request.orderByTitle(direction: collectionOrder.direction)
        case .lastUpdate: request = request.order(sql: "mangaChapter.dateSourceUpload \(collectionOrder.direction)")
        case .chapterCount: request = request.order(sql: "chapterCount \(collectionOrder.direction)")
        }
        
        return try DetailedMangaInList.fetchAll(db, request)
    }
}
