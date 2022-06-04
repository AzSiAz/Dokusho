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

struct CollectionSettings: View {
    @Environment(\.appDatabase) var appDatabase
    @Query<OneMangaCollectionRequest> var collection: MangaCollection?
    
    @State var collectionOrder: MangaCollectionOrder
    @State var collectionFilter: MangaCollectionFilter
    @State var useList: Bool
    
    init(collection : MangaCollection) {
        _collection = Query(OneMangaCollectionRequest(collectionId: collection.id))
        _collectionOrder = .init(initialValue: collection.order)
        _collectionFilter = .init(initialValue: collection.filter)
        _useList = .init(initialValue: collection.useList ?? false)
    }
    
    var body: some View {
        NavigationView {
            List {
                Section("Filter") {
                    Picker("Change collection filter", selection: $collectionFilter) {
                        ForEach(MangaCollectionFilter.allCases, id: \.self) { filter in
                            Text(filter.rawValue).tag(filter)
                        }
                    }
                }

                Section("Order") {
                    Picker("Change collection order field", selection: $collectionOrder.field) {
                        ForEach(MangaCollectionOrder.Field.allCases, id: \.self) { filter in
                            Text(filter.rawValue).tag(filter)
                        }
                    }
                    Picker("Change collection order direction", selection: $collectionOrder.direction) {
                        ForEach(MangaCollectionOrder.Direction.allCases, id: \.self) { filter in
                            Text(filter.rawValue).tag(filter)
                        }
                    }
                }
                
                Section("Presentation") {
                    Toggle("Show as list", isOn: $useList)
                }
            }
            .navigationTitle(Text("Modify Filter"))
            .onChange(of: $collectionFilter.wrappedValue, perform: { updateCollectionFilter(newFilter: $0) })
            .onChange(of: $collectionOrder.field.wrappedValue, perform: { updateCollectionOrder(direction: nil, field: $0) })
            .onChange(of: $collectionOrder.direction.wrappedValue, perform: { updateCollectionOrder(direction: $0, field: nil) })
            .onChange(of: $useList.wrappedValue, perform: { updateCollectionUseList(d: $0) })
        }
    }
    
    func updateCollectionUseList(d: Bool) {
        Task {
            guard let collection = collection else { return }

            do {
                try await appDatabase.database.write { db in
                    guard var foundCollection = try MangaCollection.fetchOne(db, id: collection.id) else { return }
                    
                    try foundCollection.updateChanges(db) {
                        $0.useList = d
                    }
                }
            } catch(let err) {
                print(err)
            }
        }
    }
    
    func updateCollectionFilter(newFilter: MangaCollectionFilter) {
        Task {
            guard let collection = collection else { return }

            do {
                try await appDatabase.database.write { db in
                    guard var foundCollection = try MangaCollection.fetchOne(db, id: collection.id) else { return }
                    
                    try foundCollection.updateChanges(db) {
                        $0.filter = newFilter
                    }
                }
            } catch(let err) {
                print(err)
            }
        }
    }
    
    func updateCollectionOrder(direction: MangaCollectionOrder.Direction? = nil, field: MangaCollectionOrder.Field? = nil) {
        Task {
            guard let collection = collection else { return }
            
            do {
                try await appDatabase.database.write { db in
                    guard var foundCollection = try MangaCollection.fetchOne(db, id: collection.id) else { return }
                    
                    try foundCollection.updateChanges(db) {
                        if let direction = direction { $0.order.direction = direction }
                        if let field = field { $0.order.field = field }
                    }
                }
            } catch(let err) {
                print(err)
            }
        }
    }
}
