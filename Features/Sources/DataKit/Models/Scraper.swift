//
//  Source.swift
//  Dokusho
//
//  Created by Stef on 21/12/2021.
//

import Foundation
@preconcurrency import GRDB
import MangaScraper

public struct Scraper: Identifiable, Equatable, Codable, Hashable, Sendable {
    public var id: UUID
    public var name: String
    public var position: Int?
    public var isFavorite: Bool
    public var isActive: Bool
    
    public init(id: UUID, name: String, position: Int? = nil, isFavorite: Bool = false, isActive: Bool = false) {
        self.id = id
        self.name = name
        self.position = position
        self.isActive = isActive
        self.isFavorite = isFavorite
    }
    
    public init(from source: Source) {
        self.id = source.id
        self.name = source.name
        self.isActive = false
        self.isFavorite = false
    }
    
    public func asSource() -> Source? {
        return MangaScraperService.shared.getSource(sourceId: self.id)
    }
}

extension Scraper: FetchableRecord, PersistableRecord {}

extension Scraper: TableRecord {
    public static let mangas = hasMany(Manga.self)
    
    public enum Columns: CaseIterable {
        public static let id = Column(CodingKeys.id)
        public static let name = Column(CodingKeys.name)
        public static let position = Column(CodingKeys.position)
        public static let isFavorite = Column(CodingKeys.isFavorite)
        public static let isActive = Column(CodingKeys.isActive)
    }
    
    public static let databaseSelection: [SQLSelectable] = [
        Columns.id,
        Columns.name,
        Columns.position,
        Columns.isActive,
        Columns.isFavorite
    ]
}

public extension DerivableRequest where RowDecoder == Scraper {
    func onlyActive(_ bool: Bool = true) -> Self {
        filter(RowDecoder.Columns.isActive == bool)
    }
    
    func onlyFavorite(_ bool: Bool = true) -> Self {
        filter(RowDecoder.Columns.isFavorite == bool)
    }
    
    func orderByPosition() -> Self {
        order(
            RowDecoder.Columns.position.ascNullsLast,
            RowDecoder.Columns.name.collating(.localizedCaseInsensitiveCompare).asc
        )
    }
}

public extension Scraper {
    static func fetchOne(_ db: Database, source: Source) throws -> Self {
        if let scraper = try Self.fetchOne(db, id: source.id) { return scraper }

        let source = Scraper(from: source)
        return try source.saved(db)
    }
    
    static func fetchOne(_ db: Database, sourceId: UUID) throws -> Self {
        if let scraper = try Self.fetchOne(db, id: sourceId) { return scraper }
        else { throw "Scraper not found" }
    }
}


public extension Scraper {
    static func fetchOrCreateFromBackup(db: Database, backup: Self) throws -> Scraper {
        if let collection = try Scraper.fetchOne(db, id: backup.id) {
            return collection
        }
        
        return try Scraper(id: backup.id, name: backup.name, position: backup.position, isFavorite: backup.isFavorite, isActive: backup.isActive).saved(db)
    }
}
