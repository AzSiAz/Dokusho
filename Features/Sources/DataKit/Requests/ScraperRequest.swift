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

public struct ScraperRequest: Queryable {
    public enum Relevant {
        case onlyActive, onlyFavorite
    }
    
    public var type: Relevant
    
    public static var defaultValue: [ScraperDB] { [] }
    
    public init(type: Relevant) {
        self.type = type
    }
    
    public func publisher(in database: AppDatabase) -> AnyPublisher<[ScraperDB], Error> {
        ValueObservation
            .tracking(fetchValue(_:))
            .publisher(in: AppDatabase.shared.database, scheduling: .immediate)
            .eraseToAnyPublisher()
    }
    
    public func fetchValue(_ db: Database) throws -> [ScraperDB] {
        let request = ScraperDB.all()

        switch type {
        case .onlyActive:
            return try request.onlyActive().onlyFavorite(false).orderByPosition().fetchAll(db)
        case .onlyFavorite:
            return try request.onlyFavorite().onlyActive().orderByPosition().fetchAll(db)
        }
    }
}
