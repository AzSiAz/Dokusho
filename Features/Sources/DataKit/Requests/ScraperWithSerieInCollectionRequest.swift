import GRDBQuery
import GRDB
import SwiftUI

public struct ScraperWithSerieCount: Decodable, FetchableRecord, Identifiable {
    public var id: UUID { scraper.id }
    public var scraper: Scraper
    public var serieCount: Int
}

public struct ScraperWithSerieInCollectionRequest: Queryable {
    public static var defaultValue: [ScraperWithSerieCount] { [] }

    public init() {}
    
    public func publisher(in database: DatabaseReader) -> DatabasePublishers.Value<[ScraperWithSerieCount]> {
        ValueObservation
            .tracking(fetchValue(_:))
            .publisher(in: database, scheduling: .immediate)
    }
    
    public func fetchValue(_ db: Database) throws -> [ScraperWithSerieCount] {
        let request = Scraper
            .select(Scraper.databaseSelection + [count(Serie.Columns.id).forKey("serieCount")])
            .joining(required: Scraper.series.isInCollection())
            .group(Scraper.Columns.id)
            .orderByPosition()

        return try ScraperWithSerieCount.fetchAll(db, request)
    }
}
