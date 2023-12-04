import GRDBQuery
import GRDB
import SwiftUI

public struct SerieCollectionWithCount: Decodable, FetchableRecord, Identifiable {
    public var id: UUID { serieCollection.id }

    public var serieCollection: SerieCollection
    public var serieCount: Int
}

public struct AllSerieCollectionWithCountRequest: Queryable {
    public static var defaultValue: [SerieCollectionWithCount] { [] }
    
    public init() {}
    
    public func publisher(in database: DatabaseReader) -> DatabasePublishers.Value<[SerieCollectionWithCount]> {
        ValueObservation
            .tracking(fetchValue(_:))
            .publisher(in: database, scheduling: .immediate)
    }
    
    public func fetchValue(_ db: Database) throws -> [SerieCollectionWithCount] {
        let request = SerieCollection
            .annotated(with: SerieCollection.series.count)
            .group(SerieCollection.Columns.id)
            .orderByPosition()

        return try SerieCollectionWithCount
            .fetchAll(db, request)
    }
}
