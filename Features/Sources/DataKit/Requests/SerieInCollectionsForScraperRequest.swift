import GRDBQuery
import GRDB
import SwiftUI

public struct SerieInCollection: Decodable, FetchableRecord {
    public var internalID: String
    public var collection: String
}

public struct SerieInCollectionsForScraperRequest: Queryable {
    public static var defaultValue: [SerieInCollection] { [] }
    
    public let scraperID: Scraper.ID
    
    public init(scraperID: Scraper.ID) {
        self.scraperID = scraperID
    }
    
    public func publisher(in database: DatabaseReader) -> DatabasePublishers.Value<[SerieInCollection]> {
        ValueObservation
            .tracking(fetchValue(_:))
            .publisher(in: database, scheduling: .immediate)
    }
    
    public func fetchValue(_ db: Database) throws -> [SerieInCollection] {
        return try Serie
            .select([Serie.Columns.internalID])
            .annotated(withRequired: Serie.serieCollection.select(SerieCollection.Columns.name.forKey("collection")))
            .whereScraper(scraperID: scraperID)
            .asRequest(of: SerieInCollection.self)
            .fetchAll(db)
    }
}
