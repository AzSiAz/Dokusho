////
////  ExploreSourceViewRequest.swift
////  Dokusho
////
////  Created by Stef on 22/12/2021.
////
//
//import Combine
//import GRDBQuery
//import GRDB
//import SwiftUI
//
//public struct MangaCollectionRequest: Queryable {
//    public static var defaultValue: [MangaCollectionDB] { [] }
//    
//    public init() {}
//    
//    public func publisher(in database: AppDatabase) -> AnyPublisher<[MangaCollectionDB], Error> {
//        ValueObservation
//            .tracking(MangaCollectionDB.all().orderByPosition().fetchAll(_:))
//            .publisher(in: database.database, scheduling: .immediate)
//            .eraseToAnyPublisher()
//    }
//}
