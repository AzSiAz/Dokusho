import GRDBQuery
import GRDB

public struct OneScraperRequest: Queryable {
    public var scraperID: Scraper.ID
    
    public static var defaultValue: Scraper? { nil }
    
    public init(scraperID: Scraper.ID) {
        self.scraperID = scraperID
    }
    
    public func publisher(in database: DatabaseReader) -> DatabasePublishers.Value<Scraper?> {
        ValueObservation
            .tracking(fetchValue(_:))
            .publisher(in: database, scheduling: .immediate)
    }

    public func fetchValue(_ db: Database) throws -> Scraper? {
        return try Scraper.all().filter(id: scraperID).fetchOne(db)
    }
}
