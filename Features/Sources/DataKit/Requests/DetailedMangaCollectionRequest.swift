////
////  DetailedMangaCollectionRequest.swift
////  Dokusho
////
////  Created by Stef on 22/12/2021
////
//
//import Combine
//import GRDBQuery
//import GRDB
//import SwiftUI
//
//public struct DetailedMangaCollection: Decodable, FetchableRecord, Identifiable {
//    public var mangaCollection: MangaCollectionDB
//    public var mangaCount: Int
//    public var id: UUID { mangaCollection.id }
//}
//
//public struct DetailedMangaCollectionRequest: Queryable {
//    public static var defaultValue: [DetailedMangaCollection] { [] }
//    
//    public init() {}
//    
//    public func publisher(in database: AppDatabase) -> AnyPublisher<[DetailedMangaCollection], Error> {
//        ValueObservation
//            .tracking(fetchValue(_:))
//            .publisher(in: database.database, scheduling: .immediate)
//            .eraseToAnyPublisher()
//    }
//    
//    public func fetchValue(_ db: Database) throws -> [DetailedMangaCollection] {
//        let request = MangaCollectionDB
//            .annotated(with: MangaCollectionDB.mangas.count)
//            .group(MangaCollectionDB.Columns.id)
//            .orderByPosition()
//
//        return try DetailedMangaCollection
//            .fetchAll(db, request)
//    }
//}
//
