//
//  ManageCollectionsModal.swift
//  Dokusho (iOS)
//
//  Created by Stephan Deumier on 26/06/2021.
//

import SwiftUI
import GRDBQuery

struct CollectionPage: View {
    @Query<OneMangaCollectionRequest> var collection: MangaCollection?
    @StateObject var vm: LibraryVM
    
    init(collection : MangaCollection) {
        _vm = .init(wrappedValue: .init(collection: collection))
        _collection = Query(OneMangaCollectionRequest(collectionId: collection.id))
    }
    
    var body: some View {
        if let collection = collection {
            ScrollView {
                FilteredCollectionPage(collection: collection, searchTerm: vm.searchTerm)
            }
            .searchable(text: $vm.searchTerm)
            .toolbar { toolbar }
            .safeAreaInset(edge: .bottom) {
                if let refresh = vm.refreshStatus {
                    ProgressView(value: Double(refresh.refreshProgress), total: Double(refresh.refreshCount)) {
                        Text(refresh.refreshTitle)
                            .lineLimit(1)
                            .padding(5)
                    }
                    .background(.thickMaterial)
                }
            }
            
        }
    }
    
    var toolbar: some ToolbarContent {
        ToolbarItemGroup(placement: .navigationBarTrailing) {
            AsyncButton(action: { try? await vm.refreshCollection() }) {
                Image(systemSymbol: .arrowClockwise)
            }
            
            Button(action: { vm.showFilter.toggle() }) {
                Image(systemSymbol: .lineHorizontal3DecreaseCircle)
                    .symbolVariant(vm.collection.filter != .all ? .fill : .none)
            }
            .sheet(isPresented: $vm.showFilter) {
                NavigationView {
                    List {
                        Section("Filter") {
                            Picker("Change collection filter", selection: $vm.collectionFilter) {
                                ForEach(MangaCollectionFilter.allCases, id: \.self) { filter in
                                    Text(filter.rawValue).tag(filter)
                                }
                            }
                        }

                        Section("Order") {
                            Picker("Change collection order field", selection: $vm.collectionOrderField) {
                                ForEach(MangaCollectionOrder.Field.allCases, id: \.self) { filter in
                                    Text(filter.rawValue).tag(filter)
                                }
                            }
                            Picker("Change collection order direction", selection: $vm.collectionOrderDirection) {
                                ForEach(MangaCollectionOrder.Direction.allCases, id: \.self) { filter in
                                    Text(filter.rawValue).tag(filter)
                                }
                            }
                        }
                    }
                    .navigationTitle(Text("Modify Filter"))
                    .onChange(of: vm.collectionFilter, perform: { vm.updateCollectionFilter(newFilter: $0) })
                    .onChange(of: vm.collectionOrderField, perform: { vm.updateCollectionOrder(direction: nil, field: $0) })
                    .onChange(of: vm.collectionOrderDirection, perform: { vm.updateCollectionOrder(direction: $0, field: nil) })
                }
            }
        }
    }
}
