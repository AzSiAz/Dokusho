import Foundation
import GRDB
import GRDBQuery

public struct SerieChaptersHistory: Decodable, FetchableRecord, Identifiable {
    public var id: SerieChapter.ID { serieChapterID }
    
    public var serieTitle: String
    public var serieCover: URL
    public var serieInternalID: String
    
    public var serieChapterID: SerieChapter.ID
    public var serieChapterTitle: String
    public var serieChapterReadAt: Date?
    public var serieChapterUploadedAt: Date
    
    public var scraperID: Scraper.ID
}

public struct SerieChaptersHistoryRequest: Queryable {
    public enum ChapterStatusHistory: String, Equatable {
        case all = "Update", read = "Read"
    }
    
    public var filter: ChapterStatusHistory = .all
    public var searchTerm: String
    
    public init(filter: ChapterStatusHistory, searchTerm: String) {
        self.filter = filter
        self.searchTerm = searchTerm
    }
    
    public static var defaultValue: [SerieChaptersHistory] { [] }
    
    public func publisher(in database: DatabaseReader) -> DatabasePublishers.Value<[SerieChaptersHistory]> {
        ValueObservation
            .tracking(fetchValue(_:))
            .publisher(in: database, scheduling: .immediate)
    }
    
    public func fetchValue(_ db: Database) throws -> [SerieChaptersHistory] {
        var request = SerieChapter
            .all()
            .select([
                SerieChapter.Columns.id.forKey("serieChapterID"),
                SerieChapter.Columns.title.forKey("serieChapterTitle"),
                SerieChapter.Columns.readAt.forKey("serieChapterReadAt"),
                SerieChapter.Columns.uploadedAt.forKey("serieChapterUploadedAt")
            ])
            .annotated(withRequired: SerieChapter.scraper.select([
                Scraper.Columns.id.forKey("scraperID")
            ]))
            .annotated(withRequired: SerieChapter.serie.select([
                Serie.Columns.title.forKey("serieTitle"),
                Serie.Columns.cover.forKey("serieCover"),
                Serie.Columns.internalID.forKey("serieInternalID")
            ]))
        
        guard let last30days = Calendar.current.date(byAdding: .day, value: -31, to: Date()) else { throw "Error constructing last 30 day calendar" }
        let dc = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: last30days)
        let date = DatabaseDateComponents(dc, format: .YMD_HMSS)

        switch self.filter {
        case .all: request = request.filter(SerieChapter.Columns.uploadedAt >= date).orderHistoryAll()
        case .read: request = request.filter(SerieChapter.Columns.readAt >= date).orderHistoryRead().onlyRead()
        }
        
        return try SerieChaptersHistory.fetchAll(db, request)
    }
}
