import GRDBQuery
import GRDB

public struct ScrapersRequest: Queryable {
    public enum FilterType {
        case all, active
    }
    
    public var filter: FilterType
    
    public static var defaultValue: [Scraper] { [] }
    
    public init(filter: FilterType = .all) {
        self.filter = filter
    }

    public func publisher(in database: DatabaseReader) -> DatabasePublishers.Value<[Scraper]> {
        ValueObservation
            .tracking(fetchValue(_:))
            .publisher(in: database, scheduling: .immediate)
    }

    public func fetchValue(_ db: Database) throws -> [Scraper] {
        let request = Scraper.all()
        
        switch (filter) {
        case .active: return try request.onlyActive().orderByPosition().fetchAll(db)
        case .all: return try request.orderByPosition().fetchAll(db)
        }
    }
}
