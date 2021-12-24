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
}

struct DetailedMangaInListRequest: Queryable {
    static var defaultValue: [DetailedMangaInList] { [] }
    
    enum RequestType: Equatable {
        case forCollection(collection: MangaCollection, searchTerm: String)
        case forScraper(scraper: Scraper)
        case forGenre(genre: String)
    }
    
    var requestType: RequestType
    
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
                count(SQL(sql: chapterCount)).forKey("chapterCount")
            ])
            .joining(optional: Manga.chapters)
            .including(required: Manga.scraper)
            .group(Manga.Columns.id)

        switch requestType {
        case .forCollection(let collection, let searchTerm):
            request = request.forCollectionId(collection.id)
            
            if !searchTerm.isEmpty { request = request.filterByName(searchTerm) }
            
            switch collection.filter {
            case .all: break
            case .onlyUnReadChapter: request = request.having(sql: "unreadChapterCount > 0")
            }

            switch collection.order.field {
            case .unreadChapters: request = request.order(sql: "unreadChapterCount \(collection.order.direction)")
            case .title: request = request.orderByTitle(direction: collection.order.direction)
            case .lastUpdate: request = request.order(sql: "mangaChapter.dateSourceUpload \(collection.order.direction)")
            case .chapterCount: request = request.order(sql: "chapterCount \(collection.order.direction)")
            }
        case .forScraper(let scraper): request = request.orderByTitle().whereSource(scraper.id)
        case .forGenre(let genre): request = request.orderByTitle().filterByGenre(genre).isInCollection()
        }
        
        return try DetailedMangaInList.fetchAll(db, request)
    }
}
