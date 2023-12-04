import GRDB
import GRDBQuery

public struct OneSerieCollectionRequest: Queryable {
    public static var defaultValue: SerieCollection? { nil }
    
    public let serieCollectionID: SerieCollection.ID
    
    public init(serieCollectionID: SerieCollection.ID) {
        self.serieCollectionID = serieCollectionID
    }
    
    public func publisher(in database: DatabaseReader) -> DatabasePublishers.Value<SerieCollection?> {
        ValueObservation
            .tracking(fetchValue(_:))
            .publisher(in: database, scheduling: .immediate)
    }
    
    public func fetchValue(_ db: Database) throws -> SerieCollection? {
        return try SerieCollection.all().filter(id: serieCollectionID).limit(1).fetchOne(db)
    }
}
