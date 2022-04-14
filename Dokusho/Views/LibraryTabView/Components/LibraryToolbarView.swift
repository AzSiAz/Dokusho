//
//  LibraryToolbarView.swift
//  LibraryToolbarView
//
//  Created by Stephan Deumier on 27/07/2021.
//

import SwiftUI

struct LibraryToolbarView: ToolbarContent {
//    @ObservedObject var vm: LibraryVM
    @ObservedObject var vm: LibraryVM

    var body: some ToolbarContent {
//        TODO: Cancel task when I know how it work^^
//        ToolbarItem(placement: .navigationBarTrailing) {
//            AsyncButton(action: { /*vm.refreshLib(for: collection)*/ }) {
//                Image(systemSymbol: .arrowClockwise)
//            }
//            .buttonStyle(.plain)
//        }
        
        ToolbarItem(placement: .navigationBarTrailing) {
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
