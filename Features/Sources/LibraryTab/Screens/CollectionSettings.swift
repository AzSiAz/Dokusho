import Foundation
import SwiftUI
import GRDBQuery
import Combine
import DataKit
import Common
import SharedUI

public struct CollectionSettings: View {
    @Environment(\.appDatabase) var appDatabase
    @Query<OneMangaCollectionRequest> var collection: MangaCollection?
    
    @State var collectionOrder: MangaCollectionOrder
    @State var collectionFilter: MangaCollectionFilter
    @State var useList: Bool
    
    public init(collection : MangaCollection) {
        _collection = Query(OneMangaCollectionRequest(collectionId: collection.id))
        _collectionOrder = .init(initialValue: collection.order)
        _collectionFilter = .init(initialValue: collection.filter)
        _useList = .init(initialValue: collection.useList ?? false)
    }
    
    public var body: some View {
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
            .onChange(of: $collectionFilter.wrappedValue) { _, filter in updateCollectionFilter(newFilter: filter) }
            .onChange(of: $collectionOrder.field.wrappedValue) { _, field in updateCollectionOrder(direction: nil, field: field) }
            .onChange(of: $collectionOrder.direction.wrappedValue) { _, direction in updateCollectionOrder(direction: direction, field: nil) }
            .onChange(of: $useList.wrappedValue) { _, useList in updateCollectionUseList(d: useList) }
        }
    }
}

extension CollectionSettings {
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
