//
//  Source.swift
//  Dokusho
//
//  Created by Stef on 21/12/2021.
//

import Foundation
import GRDB
import MangaScraper

struct Scraper: Identifiable, Equatable, Codable {
    var id: UUID
    var name: String
    var position: Int?
    var isFavorite: Bool
    var isActive: Bool
    
    init(id: UUID, name: String, position: Int? = nil, isFavorite: Bool = false, isActive: Bool = false) {
        self.id = id
        self.name = name
        self.position = position
        self.isActive = isActive
        self.isFavorite = isFavorite
    }
    
    init(from source: Source) {
        self.id = source.id
        self.name = source.name
        self.isActive = false
        self.isFavorite = false
    }
    
    func asSource() -> Source? {
        return MangaScraperService.shared.getSource(sourceId: self.id)
    }
}

extension Scraper: FetchableRecord, PersistableRecord {}

extension Scraper: TableRecord {
    static let mangas = hasMany(Manga.self)
    
    enum Columns: CaseIterable {
        static let id = Column(CodingKeys.id)
        static let name = Column(CodingKeys.name)
        static let position = Column(CodingKeys.position)
        static let isFavorite = Column(CodingKeys.isFavorite)
        static let isActive = Column(CodingKeys.isActive)
    }
    
    static let databaseSelection: [SQLSelectable] = [
        Columns.id,
        Columns.name,
        Columns.position,
        Columns.isActive,
        Columns.isFavorite
    ]
}

extension DerivableRequest where RowDecoder == Scraper {
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
