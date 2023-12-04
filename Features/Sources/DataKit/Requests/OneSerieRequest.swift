import GRDBQuery
import GRDB

public struct OneSerieRequest: Queryable {
    public var serieID: String
    public var scraperID: Scraper.ID
    
    public static var defaultValue: Serie? { nil }
    
    public init(serieID: String, scraperID: Scraper.ID) {
        self.scraperID = scraperID
        self.serieID = serieID
    }
    
    public func publisher(in database: DatabaseReader) -> DatabasePublishers.Value<Serie?> {
        ValueObservation
            .tracking(fetchValue(_:))
            .publisher(in: database, scheduling: .immediate)
    }
    
    public func fetchValue(_ db: Database) throws -> Serie? {
        return try Serie.all().whereSerie(serieID: serieID, scraperID: scraperID).fetchOne(db)
    }
}
