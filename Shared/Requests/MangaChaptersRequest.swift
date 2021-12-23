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
    var order: Order = .ASC
    var filter: ChapterStatusFilter = .all
    
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
        
        if filter == .unread {
            request = request.filter(MangaChapter.Columns.readAt == nil)
        }
        
        switch order {
        case .ASC: request = request.order(MangaChapter.Columns.position.asc)
        case .DESC: request = request.order(MangaChapter.Columns.position.desc)
        }
            
        return try request
            .fetchAll(db)
    }
}
