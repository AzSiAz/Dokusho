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

struct DetailedMangaInCollections: Identifiable, FetchableRecord, Decodable {
    var id: UUID { manga.id }
    var manga: Manga
    var unreadChapterCount: Int
}

struct DetailedMangaInCollectionsRequest: Queryable {
    static var defaultValue: [DetailedMangaInCollections] { [] }
    
    enum RequestType: Equatable {
        case forCollection(collection: MangaCollection, searchTerm: String)
    }
    
    var requestType: RequestType
    
    func publisher(in database: AppDatabase) -> AnyPublisher<[DetailedMangaInCollections], Error> {
        ValueObservation
            .tracking(fetchValue(_:))
            .publisher(in: AppDatabase.shared.database, scheduling: .immediate)
            .eraseToAnyPublisher()
    }
    
    func fetchValue(_ db: Database) throws -> [DetailedMangaInCollections] {
//        TODO: Find a way to use this kind of count
//        COUNT(DISTINCT "mangaChapter"."rowid") FILTER (WHERE mangaChapter.status = 'unread') AS "unreadChapterCount",
//        COUNT(DISTINCT "mangaChapter"."rowid") FILTER (WHERE mangaChapter.status = 'read') as "readChapterCount"

        var request = Manga
            .select(sql: "COUNT(DISTINCT \"mangaChapter\".\"rowid\") FILTER (WHERE mangaChapter.status = 'unread') AS \"unreadChapterCount\"")
            .select(sql: "COUNT(DISTINCT \"mangaChapter\".\"rowid\") FILTER (WHERE mangaChapter.status = 'read') AS \"readChapterCount\"")
            .annotated(withOptional: Manga.chapters)
            .group(Manga.Columns.id)

        switch requestType {
        case .forCollection(let collection, let searchTerm):
            request = request.forCollectionId(collection.id)
            
            if !searchTerm.isEmpty { request = request.filterByName(searchTerm) }
            
            switch collection.filter.field {
            case .all: break
            case .hasUnreadChapters: request = request.having(sql: "chapterCount > 0")
            }
            
            switch collection.order.field {
            case .unreadChapters: request = request.order(sql: "chapterCount \(collection.order.direction)")
            case .title: request = request.order(Manga.Columns.title.collating(.localizedCaseInsensitiveCompare).asc)
            case .lastUpdate: request = request.order(sql: "mangaChapter.dateSourceUpload \(collection.order.direction)")
            }
            
            return try DetailedMangaInCollections
                .fetchAll(db, request)
        }
    }
}
