import Foundation

public extension Collection {
    enum Filter: String, Codable, CaseIterable {
        case all = "All", onlyUnReadChapter = "Only unread chapter", completed = "Only completed"
    }
    
    struct Order: Codable {
        public enum Direction: String, Codable, CaseIterable {
            case ASC = "Ascending", DESC = "Descending"
        }
        
        public enum Field: String, Codable, CaseIterable {
            case unreadChapters = "By unread chapter", lastUpdate = "By last update", title = "By title", chapterCount = "By chapter count"
        }
        
        public var field: Field
        public var direction: Direction
        
        public init(field: Field = .lastUpdate, direction: Direction = .DESC) {
            self.field = field
            self.direction = direction
        }
    }
}
