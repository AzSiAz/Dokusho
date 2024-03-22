import Foundation
import GRDB
import SwiftUI
import Common

public extension SerieCollection {
    enum Filter: Int, Codable, CaseIterable, DatabaseValueConvertible, Labelized {
        case all = 0, onlyUnReadChapter = 1, completed = 2
        
        public init(_ rawValue: Int) {
            switch rawValue {
            case 0: self = .all
            case 1: self = .onlyUnReadChapter
            case 2: self = .completed
            default: self = .all
            }
        }
        
        public init(_ backup: Backup.V1.BackupFilter) {
            switch backup {
            case .all: self = .all
            case .onlyUnReadChapter: self = .onlyUnReadChapter
            case .completed: self = .completed
            }
        }
        
        public func label() -> LocalizedStringKey {
            switch self {
            case .all: "All"
            case .onlyUnReadChapter: "Only unread chapter"
            case .completed: "Only completed"
            }
        }
    }
    
    struct Order: Codable, Hashable, Equatable {
        public enum Direction: Int, Codable, CaseIterable, DatabaseValueConvertible, Labelized {
            case ASC = 0, DESC = 1
            
            public init(_ backup: Backup.V1.BackupOrder.Direction) {
                switch backup {
                case .ASC: self = .ASC
                case .DESC: self = .DESC
                }
            }
            
            public func label() -> LocalizedStringKey {
                switch self {
                case .ASC: "Ascending"
                case .DESC: "Descending"
                }
            }
        }
        
        public enum Field: Int, Codable, CaseIterable, DatabaseValueConvertible, Labelized {
            case unreadChapters = 0, lastUpdate = 1, title = 2, chapterCount = 3
            
            public init(_ backup: Backup.V1.BackupOrder.Field) {
                switch backup {
                case .chapterCount: self = .chapterCount
                case .lastUpdate: self = .lastUpdate
                case .title: self = .title
                case .unreadChapters: self = .unreadChapters
                }
            }
            
            public func label() -> LocalizedStringKey {
                switch self {
                case .unreadChapters: "By unread chapter"
                case .lastUpdate: "By last update"
                case .title: "By title"
                case .chapterCount: "By chapter count"
                }
            }
        }

        public var field: Field
        public var direction: Direction
        
        public init(field: Field = .lastUpdate, direction: Direction = .DESC) {
            self.field = field
            self.direction = direction
        }
        
        public init(_ backup: Backup.V1.BackupOrder) {
            self.field = .init(backup.field)
            self.direction = .init(backup.direction)
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
