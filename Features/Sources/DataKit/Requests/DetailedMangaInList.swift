//
//  DetailedMangaInCollectionsRequest.swift
//  Dokusho
//
//  Created by Stef on 22/12/2021.
//

import GRDB
import GRDBQuery
import Combine
import Foundation

public struct DetailedMangaInList: Identifiable, Hashable, FetchableRecord, Decodable {
    public var id: UUID { manga.id }
    public var manga: PartialManga
    public var scraper: Scraper
    public var unreadChapterCount: Int
    public var readChapterCount: Int
    public var chapterCount: Int
    public var lastUpdate: Date?
}

public struct DetailedMangaInListRequest: Queryable {
    public static var defaultValue: [DetailedMangaInList] { [] }

    public var searchTerm: String = ""
    public var genre: String?
    public var scraper: Scraper?
    public var collection: MangaCollection?
    public var collectionFilter: MangaCollectionFilter?
    public var collectionOrder: MangaCollectionOrder?
    
    public init(searchTerm: String = "", genre: String? = nil, scraper: Scraper? = nil, collection: MangaCollection? = nil, collectionFilter: MangaCollectionFilter? = nil, collectionOrder: MangaCollectionOrder? = nil) {
        self.searchTerm = searchTerm
        self.genre = genre
        self.scraper = scraper
        self.collection = collection
        self.collectionOrder = collectionOrder
        self.collectionFilter = collectionFilter
    }
    
    public func publisher(in database: AppDatabase) -> AnyPublisher<[DetailedMangaInList], Error> {
        ValueObservation
            .tracking(fetchValue(_:))
            .publisher(in: database.database, scheduling: .immediate)
            .eraseToAnyPublisher()
    }
    
    public func fetchValue(_ db: Database) throws -> [DetailedMangaInList] {
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


public struct DetailedMangaInCollectionRequest: Queryable {
    public static var defaultValue: [DetailedMangaInList] { [] }

    public var searchTerm: String = ""
    public var collection: MangaCollection
    public var collectionFilter: MangaCollectionFilter
    public var collectionOrder: MangaCollectionOrder
    
    public init(collection: MangaCollection) {
        self.collection = collection
        self.collectionFilter = collection.filter
        self.collectionOrder = collection.order
    }
    
    public func publisher(in database: AppDatabase) -> AnyPublisher<[DetailedMangaInList], Error> {
        ValueObservation
            .tracking(fetchValue(_:))
            .publisher(in: database.database, scheduling: .immediate)
            .eraseToAnyPublisher()
    }
    
    public func fetchValue(_ db: Database) throws -> [DetailedMangaInList] {
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
