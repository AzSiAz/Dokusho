//
//  MangaChaptersRequest.swift
//  Dokusho
//
//  Created by Stef on 23/12/2021.
//

import Combine
import GRDB
import GRDBQuery

public struct MangaChaptersRequest: Queryable {
    public enum Order {
        case ASC, DESC
    }
    
    public var manga: MangaDB
    public var ascendingOrder = true
    public var filterAll = true
    
    public init(manga: MangaDB) {
        self.manga = manga
    }
    
    public static var defaultValue: [MangaChapterDB] { [] }
    
    public func publisher(in database: AppDatabase) -> AnyPublisher<[MangaChapterDB], Error> {
        ValueObservation
            .tracking(fetchValue(_:))
            .publisher(in: database.database, scheduling: .immediate)
            .eraseToAnyPublisher()
    }
    
    public func fetchValue(_ db: Database) throws -> [MangaChapterDB] {
        var request = MangaChapterDB
            .all()
            .forMangaId(manga.id)
        
        if !filterAll {
            request = request.filter(MangaChapterDB.Columns.readAt == nil)
        }
        
        switch ascendingOrder {
        case true: request = request.order(MangaChapterDB.Columns.position.asc)
        case false: request = request.order(MangaChapterDB.Columns.position.desc)
        }
            
        return try request.fetchAll(db)
    }
}
