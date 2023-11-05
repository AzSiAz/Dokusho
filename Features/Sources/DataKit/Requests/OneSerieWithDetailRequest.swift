import GRDBQuery
import GRDB
import Foundation

public struct SerieWithDetail: Decodable, FetchableRecord {
    public var serie: Serie
    public var scraper: Scraper
    public var serieCollection: SerieCollection?
}

public struct OneSerieWithDetailRequest: Queryable {
    public static var defaultValue: SerieWithDetail? { nil }

    public var serieID: String
    public var scraperID: Scraper.ID

    public init(serieID: String, scraperID: Scraper.ID) {
        self.serieID = serieID
        self.scraperID = scraperID
    }

    public func publisher(in database: DatabaseReader) -> DatabasePublishers.Value<SerieWithDetail?> {
        ValueObservation
            .tracking(fetchValue(_:))
            .publisher(in: database, scheduling: .immediate)
    }
    
    public func fetchValue(_ db: Database) throws -> SerieWithDetail? {
        let request = Serie
            .all()
            .whereSerie(serieID: serieID, scraperID: scraperID)
            .including(required: Serie.scraper)
            .including(optional: Serie.serieCollection)
        
        return try SerieWithDetail.fetchOne(db, request)
    }
}
