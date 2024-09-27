//
//  Collection.swift
//  Dokusho
//
//  Created by Stef on 21/12/2021.
//

import Foundation
@preconcurrency import GRDB

public enum MangaCollectionFilter: String, Codable, Equatable, CaseIterable, DatabaseValueConvertible, Hashable, Sendable {
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

public struct MangaCollectionOrder: Codable, Equatable, DatabaseValueConvertible, Hashable, Sendable {
    public enum Field: String, Codable, CaseIterable, DatabaseValueConvertible, Hashable, Sendable {
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

    public enum Direction: String, Codable, CaseIterable, DatabaseValueConvertible, Hashable, Sendable {
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

public struct MangaCollection: Codable, Identifiable, Equatable, Hashable, Sendable {
    public var id: UUID
    public var name: String
    public var position: Int
    public var filter: MangaCollectionFilter = .all
    public var order: MangaCollectionOrder = .init()
    public var useList: Bool? = false
    
    public init(id: UUID, name: String, position: Int, filter: MangaCollectionFilter? = nil, order: MangaCollectionOrder? = nil, useList: Bool? = nil) {
        self.id = id
        self.name = name
        self.position = position
        if let filter = filter {
            self.filter = filter
        }
        if let order = order {
            self.order = order
        }
        if let useList = useList {
            self.useList = useList
        }
    }
}

extension MangaCollection: FetchableRecord, PersistableRecord {}

extension MangaCollection: TableRecord {
    public static let mangas = hasMany(Manga.self)
    
    public enum Columns {
        public static let id = Column(CodingKeys.id)
        public static let name = Column(CodingKeys.name)
        public static let position = Column(CodingKeys.position)
        public static let filter = Column(CodingKeys.filter)
        public static let order = Column(CodingKeys.order)
        public static let useList = Column(CodingKeys.useList)
    }
    
    public static let databaseSelection: [SQLSelectable] = [
        Columns.id,
        Columns.name,
        Columns.position,
        Columns.filter,
        Columns.order,
        Columns.useList
    ]
}

public extension DerivableRequest where RowDecoder == MangaCollection {
    func orderByPosition() -> Self {
        order(
            RowDecoder.Columns.position.ascNullsLast,
            RowDecoder.Columns.name.collating(.localizedCaseInsensitiveCompare).asc
        )
    }
}

public extension MangaCollection {
    static func fetchOrCreateFromBackup(db: Database, backup: Self) throws -> MangaCollection {
        if let collection = try MangaCollection.fetchOne(db, id: backup.id) {
            return collection
        }
        
        return try MangaCollection(id: backup.id, name: backup.name, position: backup.position, filter: backup.filter, order: backup.order, useList: backup.useList).saved(db)
    }
}
