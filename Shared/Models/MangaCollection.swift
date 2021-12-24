//
//  Collection.swift
//  Dokusho
//
//  Created by Stef on 21/12/2021.
//

import Foundation
import GRDB

enum MangaCollectionFilter: String, Codable, Equatable, DatabaseValueConvertible {
    case onlyUnReadChapter = "Only Unread Chapter", all = "All"
}

struct MangaCollectionOrder: Codable, Equatable, DatabaseValueConvertible {
    enum Field: String, Codable, CaseIterable, DatabaseValueConvertible {
        case unreadChapters, lastUpdate, title, chapterCount
    }

    enum Direction: String, Codable, CaseIterable, DatabaseValueConvertible {
        case ASC, DESC
    }
    
    var field: Field = .lastUpdate
    var direction: Direction = .DESC
}

struct MangaCollection: Codable, Identifiable, Equatable {
    var id: UUID
    var name: String
    var position: Int
    var filter: MangaCollectionFilter = .all
    var order: MangaCollectionOrder = .init()
}

extension MangaCollection: FetchableRecord, PersistableRecord {}

extension MangaCollection: TableRecord {
    static let mangas = hasMany(Manga.self)
    
    enum Columns {
        static let id = Column(CodingKeys.id)
        static let name = Column(CodingKeys.name)
        static let position = Column(CodingKeys.position)
        static let filter = Column(CodingKeys.filter)
        static let order = Column(CodingKeys.order)
    }
    
    static let databaseSelection: [SQLSelectable] = [
        Columns.id,
        Columns.name,
        Columns.position,
        Columns.filter,
        Columns.order
    ]
}

extension DerivableRequest where RowDecoder == MangaCollection {
    func orderByPosition() -> Self {
        order(
            RowDecoder.Columns.position.ascNullsLast,
            RowDecoder.Columns.name.collating(.localizedCaseInsensitiveCompare).asc
        )
    }
}

extension MangaCollection {
    static func fetchOrCreateFromBackup(db: Database, backup: CollectionBackup) throws -> MangaCollection {
        if let collection = try MangaCollection.fetchOne(db, id: backup.id) {
            return collection
        }
        
        return try MangaCollection(id: backup.id, name: backup.name, position: backup.position).saved(db)
    }
}
