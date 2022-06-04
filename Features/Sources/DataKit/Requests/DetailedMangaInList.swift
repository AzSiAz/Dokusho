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

public enum DetailedMangaRequestType: Equatable {
    case genre(genre: String)
    case scraper(scraper: Scraper)
    case collection(collectionId: MangaCollection.ID)
}

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

    public var requestType: DetailedMangaRequestType
    public var searchTerm: String
    
    public init(requestType: DetailedMangaRequestType, searchTerm: String = "") {
        self.requestType = requestType
        self.searchTerm = searchTerm
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

        switch requestType {
        case .genre(let genre):
            request = request.orderByTitle().filterByGenre(genre).isInCollection()
        case .scraper(let scraper):
            request = request.orderByTitle().whereSource(scraper.id).isInCollection()
        case .collection(let collectionId):
            let collection = try? MangaCollection.all().filter(id: collectionId).fetchOne(db)
            
            request = request.forCollectionId(collectionId)

            if !searchTerm.isEmpty { request = request.filterByName(searchTerm) }

            if let filter = collection?.filter {
                switch filter {
                case .all: break
                case .onlyUnReadChapter: request = request.having(sql: "unreadChapterCount > 0")
                case .completed: request = request.forMangaStatus(.complete)
                }
            }


            if let order = collection?.order {
                switch order.field {
                case .unreadChapters: request = request.order(sql: "unreadChapterCount \(order.direction)")
                case .title: request = request.orderByTitle(direction: order.direction)
                case .lastUpdate: request = request.order(sql: "mangaChapter.dateSourceUpload \(order.direction)")
                case .chapterCount: request = request.order(sql: "chapterCount \(order.direction)")
                }
            }
        }

        return try DetailedMangaInList.fetchAll(db, request)
    }
}
