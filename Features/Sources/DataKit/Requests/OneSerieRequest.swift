import GRDBQuery
import GRDB

public struct OneSerieRequest: Queryable {
    public var serieInternalID: Serie.InternalID
    public var scraperID: Scraper.ID
    
    public static var defaultValue: Serie? { nil }
    
    public init(serieInternalID: Serie.InternalID, scraperID: Scraper.ID) {
        self.scraperID = scraperID
        self.serieInternalID = serieInternalID
    }
    
    public func publisher(in database: DatabaseReader) -> DatabasePublishers.Value<Serie?> {
        ValueObservation
            .tracking(fetchValue(_:))
            .publisher(in: database, scheduling: .immediate)
    }
    
    public func fetchValue(_ db: Database) throws -> Serie? {
        return try Serie.all().whereSerie(serieInternalID: serieInternalID, scraperID: scraperID).fetchOne(db)
    }
}
