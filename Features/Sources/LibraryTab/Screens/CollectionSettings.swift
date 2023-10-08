//
//  CollectionSettings.swift
//  Dokusho
//
//  Created by Stephan Deumier on 04/06/2022.
//

import Foundation
import SwiftUI
import GRDBQuery
import Combine
import DataKit
import Common
import SharedUI

public struct CollectionSettings: View {
//    @GRDBQuery.Query<OneMangaCollectionRequest> var collection: MangaCollectionDB?
    
    @State var collectionOrder: Collection.Order
    @State var collectionFilter: Collection.Filter
    @State var useList: Bool
    
    public init(collection : Collection) {
//        _collection = Query(OneMangaCollectionRequest(collectionId: collection.id))
        _collectionOrder = .init(initialValue: collection.order)
        _collectionFilter = .init(initialValue: collection.filter)
        _useList = .init(initialValue: collection.useList ?? false)
    }
    
    public var body: some View {
        NavigationView {
            List {
                Section("Filter") {
                    Picker("Change collection filter", selection: $collectionFilter) {
                        ForEach(Collection.Filter.allCases, id: \.self) { filter in
                            Text(filter.rawValue).tag(filter)
                        }
                    }
                }

                Section("Order") {
                    Picker("Change collection order field", selection: $collectionOrder.field) {
                        ForEach(Collection.Order.Field.allCases, id: \.self) { filter in
                            Text(filter.rawValue).tag(filter)
                        }
                    }
                    Picker("Change collection order direction", selection: $collectionOrder.direction) {
                        ForEach(Collection.Order.Direction.allCases, id: \.self) { filter in
                            Text(filter.rawValue).tag(filter)
                        }
                    }
                }
                
                Section("Presentation") {
                    Toggle("Show as list", isOn: $useList)
                }
            }
            .navigationTitle(Text("Modify Filter"))
            .onChange(of: $collectionFilter.wrappedValue){ updateCollectionFilter(newFilter: $1) }
            .onChange(of: $collectionOrder.field.wrappedValue) { updateCollectionOrder(direction: nil, field: $1) }
            .onChange(of: $collectionOrder.direction.wrappedValue) { updateCollectionOrder(direction: $1, field: nil) }
            .onChange(of: $useList.wrappedValue) { updateCollectionUseList(d: $1) }
        }
    }
}

extension CollectionSettings {
    func updateCollectionUseList(d: Bool) {
//        Task {
//            guard let collection = collection else { return }
//
//            do {
//                try await appDatabase.database.write { db in
//                    guard var foundCollection = try MangaCollectionDB.fetchOne(db, id: collection.id) else { return }
//                    
//                    try foundCollection.updateChanges(db) {
//                        $0.useList = d
//                    }
//                }
//            } catch(let err) {
//                print(err)
//            }
//        }
    }
    
    func updateCollectionFilter(newFilter: Collection.Filter) {
//        Task {
//            guard let collection = collection else { return }
//
//            do {
//                try await appDatabase.database.write { db in
//                    guard var foundCollection = try MangaCollectionDB.fetchOne(db, id: collection.id) else { return }
//                    
//                    try foundCollection.updateChanges(db) {
//                        $0.filter = newFilter
//                    }
//                }
//            } catch(let err) {
//                print(err)
//            }
//        }
    }
    
    func updateCollectionOrder(direction: Collection.Order.Direction? = nil, field: Collection.Order.Field? = nil) {
//        Task {
//            guard let collection = collection else { return }
//            
//            do {
//                try await appDatabase.database.write { db in
//                    guard var foundCollection = try MangaCollectionDB.fetchOne(db, id: collection.id) else { return }
//                    
//                    try foundCollection.updateChanges(db) {
//                        if let direction = direction { $0.order.direction = direction }
//                        if let field = field { $0.order.field = field }
//                    }
//                }
//            } catch(let err) {
//                print(err)
//            }
//        }
    }
}
