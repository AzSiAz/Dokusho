import Foundation
import SerieScraper
import GRDB

public extension Serie {
    typealias InternalID = String
    
    enum Status: String, Codable, CaseIterable, DatabaseValueConvertible {
        case complete = "Complete", ongoing = "Ongoing", unknown = "Unknown"
        
        public init(from: SourceSerieCompletion) {
            switch(from) {
            case .complete: self = .complete
            case .ongoing: self = .ongoing
            case .unknown: self = .unknown
            }
        }
    }
    
    enum Kind: String, Codable, CaseIterable, DatabaseValueConvertible {
        case manga = "Manga", manhua = "Manhua", manhwa = "Manhwa", doujinshi = "Doujinshi", unknown = "Unknown", lightNovel = "Light Novel"
        
        public init(from: SourceSerieType) {
            switch(from) {
            case .doujinshi: self = .doujinshi
            case .manga: self = .manga
            case .manhua: self = .manhua
            case .manhwa: self = .manhwa
            case .lightNovel: self = .lightNovel
            case .unknown: self = .unknown
            }
        }
    }
    
    
    enum ReaderDirection: String, Codable, CaseIterable, DatabaseValueConvertible {
        case rightToLeft = "Right to Left (Manga)"
        case leftToRight = "Left to Right (Manhua)"
        case vertical = "Vertical (Webtoon, no gaps)"
        
        public init(from: SourceSerieType) {
            switch from {
                case .manga: self = .rightToLeft
                case .manhua: self = .leftToRight
                case .manhwa: self = .vertical
                case .doujinshi: self = .rightToLeft
                default: self = .rightToLeft
            }
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case id, internalID, title, cover, synopsis, alternateTitles, genres, authors, status, kind, readerDirection, scraperID, collectionID
    }
}

extension Serie: FetchableRecord, PersistableRecord {}

extension Serie: TableRecord {
    public static var databaseTableName: String = "serie"
    
    public static let scraper = belongsTo(Scraper.self)
    public static let serieCollection = belongsTo(SerieCollection.self, key: "collectionID")
    public static let chapters = hasMany(SerieChapter.self)
    
    public enum Columns {
        public static let id = Column(CodingKeys.id)
        public static let internalID = Column(CodingKeys.internalID)
        public static let title = Column(CodingKeys.title)
        public static let cover = Column(CodingKeys.cover)
        public static let synopsis = Column(CodingKeys.synopsis)
        public static let alternateTitles = Column(CodingKeys.alternateTitles)
        public static let genres = Column(CodingKeys.genres)
        public static let authors = Column(CodingKeys.authors)
        public static let status = Column(CodingKeys.status)
        public static let kind = Column(CodingKeys.kind)
        public static let readerDirection = Column(CodingKeys.readerDirection)
        public static let scraperID = Column(CodingKeys.scraperID)
        public static let collectionID = Column(CodingKeys.collectionID)
    }

    public static let databaseSelection: [SQLSelectable] = [
        Columns.id,
        Columns.internalID,
        Columns.title,
        Columns.cover,
        Columns.synopsis,
        Columns.alternateTitles,
        Columns.genres,
        Columns.authors,
        Columns.status,
        Columns.kind,
        Columns.readerDirection,
        Columns.scraperID,
        Columns.collectionID
    ]
}

public extension DerivableRequest<Serie> {
    func whereScraper(scraperID: UUID) -> Self {
        filter(RowDecoder.Columns.scraperID == scraperID)
    }

    func whereSerie(serieInternalID: Serie.InternalID, scraperID: UUID) -> Self {
        whereScraper(scraperID: scraperID).filter(RowDecoder.Columns.internalID == serieInternalID)
    }
    
    func filterByName(_ searchTerm: String) -> Self {
        let search = "%\(searchTerm)%"
        return filter(RowDecoder.Columns.title.like(search) || RowDecoder.Columns.alternateTitles.like(search))
    }
    
    func isInCollection(_ bool: Bool = true) -> Self {
        filter(bool ? RowDecoder.Columns.collectionID != nil : RowDecoder.Columns.collectionID == nil)
    }
    
    func filterByGenre(_ genre: String) -> Self {
        filter(RowDecoder.Columns.genres.like("%\(genre)%"))
    }
    
    func orderByTitle(direction: SerieCollection.Order.Direction = .ASC) -> Self {
        switch direction {
        case .ASC: return order(RowDecoder.Columns.title.collating(.localizedCaseInsensitiveCompare).ascNullsLast)
        case .DESC: return order(RowDecoder.Columns.title.collating(.localizedCaseInsensitiveCompare).desc)
        }
    }
    
    func forSerieCollectionID(_ serieCollectionID: SerieCollection.ID) -> Self {
        filter(RowDecoder.Columns.collectionID == serieCollectionID)
    }
    
    func forSerieStatus(_ status: Serie.Status) -> Self {
        filter(RowDecoder.Columns.status == status)
    }
}
