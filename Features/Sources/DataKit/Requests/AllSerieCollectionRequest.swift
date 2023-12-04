import Foundation
import GRDBQuery
import GRDB

public struct AllSerieCollectionRequest: Queryable {
    public static var defaultValue: [SerieCollection] { [] }
    
    public init() {}
    
    public func publisher(in database: DatabaseReader) -> DatabasePublishers.Value<[SerieCollection]> {
        ValueObservation
            .tracking(SerieCollection.all().orderByPosition().fetchAll(_:))
            .publisher(in: database, scheduling: .immediate)
    }
}
