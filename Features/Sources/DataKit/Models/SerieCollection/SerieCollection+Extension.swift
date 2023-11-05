import Foundation
import GRDB

public extension SerieCollection {
    enum Filter: String, Codable, CaseIterable, DatabaseValueConvertible {
        case all = "All", onlyUnReadChapter = "Only unread chapter", completed = "Only completed"
    }
    
    struct Order: Codable, Hashable, Equatable {
        public enum Direction: String, Codable, CaseIterable, DatabaseValueConvertible {
            case ASC = "Ascending", DESC = "Descending"
        }
        
        public enum Field: String, Codable, CaseIterable, DatabaseValueConvertible {
            case unreadChapters = "By unread chapter", lastUpdate = "By last update", title = "By title", chapterCount = "By chapter count"
        }
        
        public var field: Field
        public var direction: Direction
        
        public init(field: Field = .lastUpdate, direction: Direction = .DESC) {
            self.field = field
            self.direction = direction
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case id, name, position, useList, filter, order
    }
}

/// GRDB extension
extension SerieCollection: FetchableRecord, PersistableRecord {}

extension SerieCollection: TableRecord {
    public static var databaseTableName: String = "serieCollection"
    
    public static let series = hasMany(Serie.self)
    
    public enum Columns {
        public static let id = Column(CodingKeys.id)
        public static let name = Column(CodingKeys.name)
        public static let position = Column(CodingKeys.position)
        public static let useList = Column(CodingKeys.useList)
        public static let filter = Column(CodingKeys.filter)
        public static let order = Column(CodingKeys.order)
    }
    
    public static let databaseSelection: [SQLSelectable] = [
        Columns.id,
        Columns.name,
        Columns.position,
        Columns.useList,
        Columns.filter,
        Columns.order
    ]
}

public extension DerivableRequest<SerieCollection> {
    func orderByPosition() -> Self {
        order(
            RowDecoder.Columns.position.ascNullsLast,
            RowDecoder.Columns.name.collating(.localizedCaseInsensitiveCompare).asc
        )
    }
}
