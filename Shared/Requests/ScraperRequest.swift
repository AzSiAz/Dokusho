//
//  ExploreTabViewRequest.swift
//  Dokusho
//
//  Created by Stef on 21/12/2021.
//

import Combine
import GRDBQuery
import GRDB
import SwiftUI

struct ScraperRequest: Queryable {
    enum Relevant {
        case onlyActive, onlyFavorite
    }
    
    var type: Relevant
    
    static var defaultValue: [Scraper] { [] }
    
    func publisher(in database: AppDatabase) -> AnyPublisher<[Scraper], Error> {
        ValueObservation
            .tracking(fetchValue(_:))
            .publisher(in: AppDatabase.shared.database, scheduling: .immediate)
            .eraseToAnyPublisher()
    }
    
    func fetchValue(_ db: Database) throws -> [Scraper] {
        let request = Scraper.all()

        switch type {
        case .onlyActive:
            return try request.onlyActive().onlyFavorite(false).orderByPosition().fetchAll(db)
        case .onlyFavorite:
            return try request.onlyFavorite().onlyActive().orderByPosition().fetchAll(db)
        }
    }
}
