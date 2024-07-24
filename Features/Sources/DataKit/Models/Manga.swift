//
//  Manga.swift
//  Dokusho
//
//  Created by Stef on 22/12/2021.
//

import Foundation
import MangaScraper
import GRDB

extension SourceMangaCompletion: @retroactive StatementBinding {}
extension SourceMangaCompletion: @retroactive SQLExpressible {}
extension SourceMangaCompletion: Codable, @retroactive DatabaseValueConvertible {}
extension SourceMangaType: @retroactive StatementBinding {}
extension SourceMangaType: @retroactive SQLExpressible {}
extension SourceMangaType: Codable, @retroactive DatabaseValueConvertible {}

public enum ReadingDirection: String, CaseIterable {
    case rightToLeft = "Right to Left (Manga)"
    case leftToRight = "Left to Right (Manhua)"
    case vertical = "Vertical (Webtoon, no gaps)"
}

public struct PartialManga: Decodable, Identifiable, Hashable {
    public var id: UUID
    public var mangaId: String
    public var title: String
    public var cover: URL
    public var scraperId: UUID?
}

public struct RefreshManga: Identifiable, Hashable, FetchableRecord, Decodable {
    public var id: String { mangaId }
    public var title: String
    public var mangaId: String
    public var scraper: Scraper
    public var unreadChapterCount: Int
}

public struct Manga: Identifiable, Equatable, Codable {
    public var id: UUID
    public var mangaId: String
    public var title: String
    public var cover: URL
    public var synopsis: String
    public var alternateTitles: [String]
    public var genres: [String]
    public var authors: [String]
    public var artists: [String]
    public var status: SourceMangaCompletion
    public var type: SourceMangaType
    public var scraperId: UUID?
    public var mangaCollectionId: UUID?

    public init(mangaId: String, title: String, cover: URL, synopsis: String, alternateTitles: [String] = [], genres: [String] = [], authors: [String] = [], artists: [String] = [], status: SourceMangaCompletion = .unknown, type: SourceMangaType = .unknown) {
        self.id = UUID()
        self.mangaId = mangaId
        self.title = title
        self.cover = cover
        self.synopsis = synopsis
        self.alternateTitles = alternateTitles
        self.genres = genres
        self.authors = authors
        self.artists = artists
        self.status = status
        self.type = type
    }
    
    public init(from data: SourceManga, sourceId: UUID) {
        self.id = UUID()
        self.mangaId = data.id
        self.title = data.title
        self.cover = URL(string: data.cover)!
        self.synopsis = data.synopsis
        self.alternateTitles = data.alternateNames
        self.genres = data.genres
        self.authors = data.authors
        self.artists = data.authors
        self.status = data.status
        self.type = data.type

        self.scraperId = sourceId
    }
    
    public func getDefaultReadingDirection() -> ReadingDirection {
        switch self.type {
            case .manga:
                return .rightToLeft
            case .manhua:
                return .leftToRight
            case .manhwa:
                return .vertical
            case .doujinshi:
                return .rightToLeft
            default:
                return .rightToLeft
        }
    }
    
    public mutating func updateFromSource(from data: SourceManga) {
        self.title = data.title
        self.cover = URL(string: data.cover)!
        self.synopsis = data.synopsis
        self.alternateTitles = data.alternateNames
        self.genres = data.genres
        self.authors = data.authors
        self.artists = data.authors
        self.status = data.status
        self.type = data.type
    }
}

extension Manga: FetchableRecord, MutablePersistableRecord {}

extension Manga: TableRecord {
    public static let scraper = belongsTo(Scraper.self)
    public static let mangaCollection = belongsTo(MangaCollection.self)
    public static let chapters = hasMany(MangaChapter.self)
    
    public enum Columns {
        public static let id = Column(CodingKeys.id)
        public static let title = Column(CodingKeys.title)
        public static let cover = Column(CodingKeys.cover)
        public static let synopsis = Column(CodingKeys.synopsis)
        public static let mangaId = Column(CodingKeys.mangaId)
        public static let alternateTitles = Column(CodingKeys.alternateTitles)
        public static let genres = Column(CodingKeys.genres)
        public static let authors = Column(CodingKeys.authors)
        public static let artists = Column(CodingKeys.artists)
        public static let status = Column(CodingKeys.status)
        public static let type = Column(CodingKeys.type)
        public static let scraperId = Column(CodingKeys.scraperId)
        public static let mangaCollectionId = Column(CodingKeys.mangaCollectionId)
    }
    
    public static let databaseSelection: [SQLSelectable] = [
        Columns.id,
        Columns.title,
        Columns.cover,
        Columns.synopsis,
        Columns.mangaId,
        Columns.alternateTitles,
        Columns.genres,
        Columns.authors,
        Columns.artists,
        Columns.status,
        Columns.type,
        Columns.scraperId,
        Columns.mangaCollectionId
    ]
}

public extension DerivableRequest where RowDecoder == Manga {
    func whereSource(_ srcId: UUID) -> Self {
        filter(RowDecoder.Columns.scraperId == srcId)
    }
    
    func isInCollection(_ bool: Bool = true) -> Self {
        filter(bool ? RowDecoder.Columns.mangaCollectionId != nil : RowDecoder.Columns.mangaCollectionId == nil)
    }
    
    func forCollectionId(_ collectionId: UUID) -> Self {
        filter(RowDecoder.Columns.mangaCollectionId == collectionId)
    }
    
    func filterByName(_ searchTerm: String) -> Self {
        let search = "%\(searchTerm)%"
        return filter(RowDecoder.Columns.title.like(search) || RowDecoder.Columns.alternateTitles.like(search))
    }
    
    func filterByGenre(_ genre: String) -> Self {
        filter(RowDecoder.Columns.genres.like("%\(genre)%"))
    }
    
    func orderByTitle(direction: MangaCollectionOrder.Direction = .ASC) -> Self {
        switch direction {
        case .ASC: return order(RowDecoder.Columns.title.collating(.localizedCaseInsensitiveCompare).ascNullsLast)
        case .DESC: return order(RowDecoder.Columns.title.collating(.localizedCaseInsensitiveCompare).desc)
        }
    }
    
    func forMangaId(_ mangaId: String, _ scraperId: UUID) -> Self {
        whereSource(scraperId).filter(RowDecoder.Columns.mangaId == mangaId)
    }
    
    func forMangaStatus(_ status: SourceMangaCompletion) -> Self {
        filter(RowDecoder.Columns.status == status)
    }
}

public struct MangaWithDetail: Decodable, FetchableRecord {
    public var manga: Manga
    public var mangaCollection: MangaCollection?
    public var scraper: Scraper?
}

public extension Manga {
    static func fetchForUpdate(_ db: Database, collectionId: UUID, onlyAllRead: Bool = true) throws -> [RefreshManga] {
        let unreadChapterCount = "DISTINCT \"mangaChapter\".\"rowid\") FILTER (WHERE mangaChapter.status = 'unread'"

        var query = Manga
            .select([
                Manga.Columns.title,
                Manga.Columns.scraperId,
                Manga.Columns.mangaId,
                count(SQL(sql: unreadChapterCount)).forKey("unreadChapterCount"),
            ])
            .joining(optional: Manga.chapters)
            .including(required: Manga.scraper)
            .forCollectionId(collectionId)
            .group(Manga.Columns.id)
        
        if onlyAllRead {
            query = query.having(sql: "unreadChapterCount = 0")
        }
        
        return try RefreshManga.fetchAll(db, query)
    }
    
    static func fetchOne(_ db: Database, mangaId: String, scraperId: UUID) throws -> Manga? {
        return try Manga.all().forMangaId(mangaId, scraperId).fetchOne(db)
    }
    
    static func fetchMangaWithDetail(for mangaId: String, in scraperId: UUID, _ db: Database) throws -> MangaWithDetail? {
        let request = Manga
            .all()
            .forMangaId(mangaId, scraperId)
            .including(optional: Manga.scraper)
            .including(optional: Manga.mangaCollection)
        
        return try MangaWithDetail.fetchOne(db, request)
    }
    
    @discardableResult
    static func updateFromSource(db: Database, scraper: Scraper, data: SourceManga) throws -> Manga {
        if var manga = try Manga.all().forMangaId(data.id, scraper.id).fetchOne(db) {
            manga.updateFromSource(from: data)

            try manga.save(db)
            try MangaChapter.updateFromSource(db: db, manga: manga, scraper: scraper, data: data)
            
            return manga
        }
        
        var manga = Manga(from: data, sourceId: scraper.id)
        try manga.save(db)
        
        try MangaChapter.updateFromSource(db: db, manga: manga, scraper: scraper, data: data)
        
        return manga
    }
    
    static func updateCollection(id: UUID, collectionId: UUID?, _ db: Database) throws {
        return try db.execute(sql: """
            UPDATE "manga" SET "mangaCollectionId" = ? WHERE id = ?
        """, arguments: [collectionId, id])
    }
}
