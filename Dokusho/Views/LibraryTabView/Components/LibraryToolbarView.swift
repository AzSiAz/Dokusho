//
//  LibraryToolbarView.swift
//  LibraryToolbarView
//
//  Created by Stephan Deumier on 27/07/2021.
//

import SwiftUI

struct LibraryToolbarView: ToolbarContent {
    @Environment(\.appDatabase) var appDB

    var collection: MangaCollection

    @Binding var showFilter: Bool
    @Binding var collectionFilter: MangaCollectionFilter
    @Binding var collectionOrderField: MangaCollectionOrder.Field
    @Binding var collectionOrderDirection: MangaCollectionOrder.Direction

    
    init(collection: MangaCollection,
         showFilter: Binding<Bool>,
         collectionFilter: Binding<MangaCollectionFilter>,
         collectionOrderField: Binding<MangaCollectionOrder.Field>,
         collectionOrderDirection: Binding<MangaCollectionOrder.Direction>
    ) {
        _collectionFilter = collectionFilter
        _showFilter = showFilter
        _collectionOrderField = collectionOrderField
        _collectionOrderDirection = collectionOrderDirection
        self.collection = collection
    }

    var body: some ToolbarContent {
//        TODO: Cancel task when I know how it work^^
//        ToolbarItem(placement: .navigationBarTrailing) {
//            AsyncButton(action: { /*vm.refreshLib(for: collection)*/ }) {
//                Image(systemSymbol: .arrowClockwise)
//            }
//            .buttonStyle(.plain)
//        }
        
        ToolbarItem(placement: .navigationBarTrailing) {
            Button(action: { showFilter.toggle() }) {
                Image(systemSymbol: .lineHorizontal3DecreaseCircle)
                    .symbolVariant(collection.filter != .all ? .fill : .none)
            }
            .sheet(isPresented: $showFilter) {
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
                            Picker("Change collection order field", selection: $collectionOrderField) {
                                ForEach(MangaCollectionOrder.Field.allCases, id: \.self) { filter in
                                    Text(filter.rawValue).tag(filter)
                                }
                            }
                            Picker("Change collection order direction", selection: $collectionOrderDirection) {
                                ForEach(MangaCollectionOrder.Direction.allCases, id: \.self) { filter in
                                    Text(filter.rawValue).tag(filter)
                                }
                            }
                        }
                    }
                    .navigationTitle(Text("Modify Filter"))
                    .onChange(of: collectionFilter, perform: { updateCollectionFilter(newFilter: $0) })
                    .onChange(of: collectionOrderField, perform: { updateCollectionOrder(direction: nil, field: $0) })
                    .onChange(of: collectionOrderDirection, perform: { updateCollectionOrder(direction: $0, field: nil) })
                }
            }
        }
    }
    
    func updateCollectionFilter(newFilter: MangaCollectionFilter) {
        do {
            try AppDatabase.shared.database.write { db in
                guard var foundCollection = try MangaCollection.fetchOne(db, id: collection.id) else { return }
                print(foundCollection)
                foundCollection.filter = newFilter
                print(foundCollection)

                try foundCollection.save(db)
            }
        } catch(let err) {
            print(err)
        }
    }
    
    func updateCollectionOrder(direction: MangaCollectionOrder.Direction? = nil, field: MangaCollectionOrder.Field? = nil) {
        do {
            try AppDatabase.shared.database.write { db in
                guard var foundCollection = try MangaCollection.fetchOne(db, id: collection.id) else { return }
                if let direction = direction { foundCollection.order.direction = direction }
                if let field = field { foundCollection.order.field = field }

                try foundCollection.save(db)
            }
        } catch(let err) {
            print(err)
        }
    }
}
