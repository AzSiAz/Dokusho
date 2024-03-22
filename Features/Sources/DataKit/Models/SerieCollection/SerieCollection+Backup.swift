//
//  File.swift
//  
//
//  Created by Stephan Deumier on 22/03/2024.
//

import Foundation

public extension SerieCollection {
    init(backup: Backup.V1) {
        self.id = backup.id
        self.name = backup.name
        self.position = backup.position
        self.useList = backup.useList
        self.filter = Filter(backup.filter)
        self.order = Order(backup.order)
    }
    
    init(backup: Backup.V2) {
        self.id = backup.id
        self.name = backup.name
        self.position = backup.position
        self.useList = backup.useList
        self.filter = Filter(backup.filter.rawValue)
        self.order = Order(field: backup.order.field, direction: backup.order.direction)
    }

    struct Backup {
        public struct V1: Codable {
            public enum BackupFilter: String, Codable, Equatable, CaseIterable, DatabaseValueConvertible, Hashable {
                case onlyUnReadChapter = "Only Unread Chapter", all = "All", completed = "Only Completed"
                
                public init(rawValue: String) {
                    switch rawValue.lowercased() {
                    case "only unread chapter": self = .onlyUnReadChapter
                        
                    case "all": self = .all
                        
                    case "only completed": self = .completed
                        
                    default: self = .all
                    }
                }
            }
            
            public struct BackupOrder: Codable, Equatable, DatabaseValueConvertible, Hashable {
                public enum Field: String, Codable, CaseIterable, DatabaseValueConvertible, Hashable {
                    case unreadChapters = "By unread chapter", lastUpdate = "By last update", title = "By title", chapterCount = "By chapter count"
                    
                    public init(rawValue: String) {
                        switch rawValue.lowercased() {
                        case "by unread chapter": fallthrough
                        case "unreadchapters": self = .unreadChapters
                            
                        case "by last update": fallthrough
                        case "lastupdate": self = .lastUpdate
                            
                        case "by title": fallthrough
                        case "title": self = .title
                            
                        case "by chapter count": fallthrough
                        case "chaptercount": self = .chapterCount
                            
                        default: self = .lastUpdate
                        }
                    }
                }
                
                public enum Direction: String, Codable, CaseIterable, DatabaseValueConvertible, Hashable {
                    case ASC = "Ascending", DESC = "Descending"
                    
                    public init(rawValue: String) {
                        switch rawValue.lowercased() {
                        case "ascending": fallthrough
                        case "asc": self = .ASC
                            
                        case "descending": fallthrough
                        case "desc": self = .DESC
                            
                        default: self = .ASC
                        }
                    }
                }
                
                public var field: Field = .lastUpdate
                public var direction: Direction = .DESC
            }
            
            
            public var id: UUID
            public var name: String
            public var position: Int
            public var filter: BackupFilter
            public var order: BackupOrder
            public var useList: Bool
        }
        
        public typealias V2 = SerieCollection
    }
}
