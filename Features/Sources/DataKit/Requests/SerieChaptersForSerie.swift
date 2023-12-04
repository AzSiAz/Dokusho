import Foundation
import GRDBQuery
import GRDB

public struct SerieChaptersForSerie: Queryable {
    public enum Order {
        case asc, desc
        
        public mutating func toggle() {
            switch self {
            case .asc: self = .desc
            case .desc: self = .asc
            }
        }
    }
    
    public enum Filter {
        case read, all, unread
        
        public mutating func toggle() {
            switch self {
            case .read: self = .all
            case .all: self = .unread
            case .unread: self = .read
            }
        }
    }
    
    public static var defaultValue: [SerieChapter] { [] }
    
    public var serieID: Serie.ID
    public var order: Order = .desc
    public var filter: Filter = .all
    
    public init(serieID: Serie.ID) {
        self.serieID = serieID
    }
    
    public func publisher(in database: DatabaseReader) -> DatabasePublishers.Value<[SerieChapter]> {
        ValueObservation
            .tracking(fetchValue(_:))
            .publisher(in: database, scheduling: .immediate)
    }
    
    public func fetchValue(_ db: Database) throws -> [SerieChapter] {
        var request = SerieChapter.all().whereSerie(serieID: serieID).orderByPosition(asc: order == .asc)
        
        switch filter {
        case .read:
            request = request.onlyRead()
        case .all: break
        case .unread:
            request = request.onlyUnRead()
        }
        
        return try request.fetchAll(db)
    }
}
