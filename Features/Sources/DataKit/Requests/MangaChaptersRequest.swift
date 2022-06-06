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
    
    public var manga: Manga
    public var ascendingOrder = true
    public var filterAll = true
    
    public init(manga: Manga) {
        self.manga = manga
    }
    
    public static var defaultValue: [MangaChapter] { [] }
    
    public func publisher(in database: AppDatabase) -> AnyPublisher<[MangaChapter], Error> {
        ValueObservation
            .tracking(fetchValue(_:))
            .publisher(in: database.database, scheduling: .immediate)
            .eraseToAnyPublisher()
    }
    
    public func fetchValue(_ db: Database) throws -> [MangaChapter] {
        var request = MangaChapter
            .all()
            .forMangaId(manga.id)
        
        if !filterAll {
            request = request.filter(MangaChapter.Columns.readAt == nil)
        }
        
        switch ascendingOrder {
        case true: request = request.order(MangaChapter.Columns.position.asc)
        case false: request = request.order(MangaChapter.Columns.position.desc)
        }
            
        return try request.fetchAll(db)
    }
}
