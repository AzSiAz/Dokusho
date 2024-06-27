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
            
            public func label() -> LocalizedStringKey {
                switch self {
                case .ASC: "Ascending"
                case .DESC: "Descending"
                }
            }
        }
        
        public enum Field: Int, Codable, CaseIterable, DatabaseValueConvertible, Labelized {
            case unreadChapters = 0, lastUpdate = 1, title = 2, chapterCount = 3
            
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
    }
    
    enum CodingKeys: String, CodingKey {
        case id, name, position, useList, filter, order
    }
}
