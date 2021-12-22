//
//  ExploreSourceViewRequest.swift
//  Dokusho
//
//  Created by Stef on 22/12/2021.
//

import Combine
import GRDBQuery
import GRDB
import SwiftUI

struct MangaCollectionRequest: Queryable {
    static var defaultValue: [MangaCollection] { [] }
    
    func publisher(in database: AppDatabase) -> AnyPublisher<[MangaCollection], Error> {
        ValueObservation
            .tracking(MangaCollection.all().orderByPosition().fetchAll(_:))
            .publisher(in: AppDatabase.shared.database, scheduling: .immediate)
            .eraseToAnyPublisher()
    }
}
