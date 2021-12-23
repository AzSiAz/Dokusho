//
//  Manga.swift
//  Dokusho
//
//  Created by Stef on 22/12/2021.
//

import Foundation
import MangaScraper
import GRDB

extension SourceMangaCompletion: Codable, DatabaseValueConvertible {}
extension SourceMangaType: Codable, DatabaseValueConvertible {}

enum ReadingDirection: String, CaseIterable {
    case rightToLeft = "Right to Left (Manga)"
    case leftToRight = "Left to Right (Manhua)"
    case vertical = "Vertical (Webtoon, no gaps)"
}

struct PartialManga: Decodable, Identifiable {
    var id: UUID
    var mangaId: String
    var title: String
    var cover: URL
    var scraperId: UUID?
}

struct Manga: Identifiable, Equatable, Codable {
    var id: UUID
    var mangaId: String
    var title: String
    var cover: URL
    var synopsis: String
    var alternateTitles: [String]
    var genres: [String]
    var authors: [String]
    var artists: [String]
    var status: SourceMangaCompletion
    var type: SourceMangaType
    var scraperId: UUID?
    var mangaCollectionId: UUID?

    init(mangaId: String, title: String, cover: URL, synopsis: String, alternateTitles: [String] = [], genres: [String] = [], authors: [String] = [], artists: [String] = [], status: SourceMangaCompletion = .unknown, type: SourceMangaType = .unknown) {
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
    
    init(from data: SourceManga, sourceId: UUID) {
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
    
    func getDefaultReadingDirection() -> ReadingDirection {
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
                return .vertical
        }
    }
}

extension Manga: FetchableRecord, MutablePersistableRecord {}

extension Manga: TableRecord {
    static let scraper = belongsTo(Scraper.self)
    static let mangaCollection = belongsTo(MangaCollection.self)
    static let chapters = hasMany(MangaChapter.self)
    
    enum Columns {
        static let id = Column(CodingKeys.id)
        static let title = Column(CodingKeys.title)
        static let cover = Column(CodingKeys.cover)
        static let synopsis = Column(CodingKeys.synopsis)
        static let mangaId = Column(CodingKeys.mangaId)
        static let alternateTitles = Column(CodingKeys.alternateTitles)
        static let genres = Column(CodingKeys.genres)
        static let authors = Column(CodingKeys.authors)
        static let artists = Column(CodingKeys.artists)
        static let status = Column(CodingKeys.status)
        static let type = Column(CodingKeys.type)
        static let scraperId = Column(CodingKeys.scraperId)
        static let mangaCollectionId = Column(CodingKeys.mangaCollectionId)
    }
    
    static let databaseSelection: [SQLSelectable] = [
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

extension DerivableRequest where RowDecoder == Manga {
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
        return filter(RowDecoder.Columns.title.like(search)).filter(RowDecoder.Columns.alternateTitles.like(search))
    }
    
    func filterByGenre(_ genre: String) -> Self {
        return filter(RowDecoder.Columns.genres.like("%\(genre)%"))
    }
    
    func orderByTitle() -> Self {
        order(Manga.Columns.title.collating(.localizedCaseInsensitiveCompare).asc)
    }
}
