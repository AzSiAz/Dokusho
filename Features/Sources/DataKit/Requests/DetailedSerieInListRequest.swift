import GRDB
import GRDBQuery
import Foundation

public enum DetailedSerieRequestType: Equatable {
    case genre(genre: String)
    case scraper(scraper: Scraper)
    case collection(collectionId: SerieCollection.ID)
}

public struct DetailedSerieInList: Identifiable, Hashable, FetchableRecord, Decodable {
    public var id: UUID { serie.id }
    public var serie: Serie
    public var scraper: Scraper
    public var unreadChapterCount: Int
    public var readChapterCount: Int
    public var chapterCount: Int
    public var lastUpdate: Date?
}

public struct DetailedSerieInListRequest: Queryable {
    public static var defaultValue: [DetailedSerieInList] { [] }

    public var requestType: DetailedSerieRequestType
    public var searchTerm: String
    
    public init(requestType: DetailedSerieRequestType, searchTerm: String = "") {
        self.requestType = requestType
        self.searchTerm = searchTerm
    }
    
    public func publisher(in database: DatabaseReader) -> DatabasePublishers.Value<[DetailedSerieInList]> {
        ValueObservation
            .tracking(fetchValue(_:))
            .publisher(in: database, scheduling: .immediate)
    }
    
    public func fetchValue(_ db: Database) throws -> [DetailedSerieInList] {
        let unreadChapterCount = "DISTINCT \"SerieChapter\".\"id\") FILTER (WHERE serieChapter.readAt = null"
        let readChapterCount = "DISTINCT \"SerieChapter\".\"id\") FILTER (WHERE serieChapter.readAt != null"
        let chapterCount = "DISTINCT \"serieChapter\".\"id\""
        
        var request = Serie
            .select([
                Serie.Columns.alternateTitles,
                Serie.Columns.authors,
                Serie.Columns.collectionID,
                Serie.Columns.cover,
                Serie.Columns.genres,
                Serie.Columns.id,
                Serie.Columns.internalID,
                Serie.Columns.kind,
                Serie.Columns.readerDirection,
                Serie.Columns.scraperID,
                Serie.Columns.status,
                Serie.Columns.synopsis,
                Serie.Columns.title,
                count(SQL(sql: unreadChapterCount)).forKey("unreadChapterCount"),
                count(SQL(sql: readChapterCount)).forKey("readChapterCount"),
                count(SQL(sql: chapterCount)).forKey("chapterCount"),
                max(SQL(sql: "\"serieChapter\".\"uploadedAt\"")).forKey("lastUpdate")
            ])
            .joining(optional: Serie.chapters)
            .including(required: Serie.scraper)
            .group(Serie.Columns.id)
        
        if !searchTerm.isEmpty { request = request.filterByName(searchTerm) }
        
        switch requestType {
        case .genre(let genre):
            request = request.orderByTitle().filterByGenre(genre).isInCollection()
        case .scraper(let scraper):
            request = request.orderByTitle().whereScraper(scraperID: scraper.id).isInCollection()
        case .collection(let collectionId):
            let serieCollection = try? SerieCollection.all().filter(id: collectionId).fetchOne(db)
            
            request = request.forSerieCollectionID(collectionId)
            
            if let filter = serieCollection?.filter {
                switch filter {
                case .all: break
                case .onlyUnReadChapter: request = request.having(sql: "unreadChapterCount > 0")
                case .completed: request = request.forSerieStatus(.complete)
                }
            }
            
            
            if let order = serieCollection?.order {
                switch order.field {
                case .unreadChapters: request = request.order(sql: "unreadChapterCount \(order.direction)")
                case .title: request = request.orderByTitle(direction: order.direction)
                case .lastUpdate: request = request.order(sql: "serieChapter.uploadedAt \(order.direction)")
                case .chapterCount: request = request.order(sql: "chapterCount \(order.direction)")
                }
            }
        }
        
        return try DetailedSerieInList.fetchAll(db, request)
    }
}
