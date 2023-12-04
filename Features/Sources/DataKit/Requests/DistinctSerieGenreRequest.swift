import GRDBQuery
import GRDB
import SwiftUI

public struct GenreWithSerieCount: Decodable, FetchableRecord, Identifiable {
    public var id: String { genre }
    public var genre: String
    public var serieCount: Int
}

public struct DistinctSerieGenreRequest: Queryable {
    public static var defaultValue: [GenreWithSerieCount] { [] }
    
    public init() {}
    
    public func publisher(in database: DatabaseReader) -> DatabasePublishers.Value<[GenreWithSerieCount]> {
        ValueObservation
            .tracking(fetchValue(_:))
            .publisher(in: database, scheduling: .immediate)
    }
    
    public func fetchValue(_ db: Database) throws -> [GenreWithSerieCount] {
        return try GenreWithSerieCount.fetchAll(db, sql: """
            SELECT DISTINCT(t2.value) as genre, COUNT(DISTINCT(t1.rowid)) as serieCount
            FROM serie AS t1
            JOIN json_each((SELECT genres FROM serie WHERE id = t1.id)) AS t2
            WHERE t1."collectionID" IS NOT NULL
            GROUP BY t2.value;
        """)
    }
}
