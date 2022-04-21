//
//  MangaChaptersRequest.swift
//  Dokusho
//
//  Created by Stef on 23/12/2021.
//

import Combine
import GRDB
import GRDBQuery

struct MangaChaptersRequest: Queryable {
    enum Order {
        case ASC, DESC
    }
    
    var manga: Manga
    var ascendingOrder = true
    var filterAll = true
    
    static var defaultValue: [MangaChapter] { [] }
    
    func publisher(in database: AppDatabase) -> AnyPublisher<[MangaChapter], Error> {
        ValueObservation
            .tracking(fetchValue(_:))
            .publisher(in: database.database, scheduling: .immediate)
            .eraseToAnyPublisher()
    }
    
    func fetchValue(_ db: Database) throws -> [MangaChapter] {
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
