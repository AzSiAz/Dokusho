//
//  LibraryToolbarView.swift
//  LibraryToolbarView
//
//  Created by Stephan Deumier on 27/07/2021.
//

import SwiftUI

struct LibraryToolbarView: ToolbarContent {
    @ObservedObject var vm: LibraryVM
    
    @Binding var showFilter: Bool
    @Binding var showSettingsModal: Bool
    
    let collection: CollectionEntity

    var body: some ToolbarContent {
        ToolbarItem {
            Button(action: { showSettingsModal.toggle() } ) {
                Image(systemName: "list.bullet.rectangle")
            }
            .buttonStyle(.plain)
        }
        
        ToolbarItem(placement: .navigationBarLeading) {
            if let collection = collection {
                // TODO: Cancel task when I know how it work^^
                AsyncButton(action: { vm.refreshLib(for: collection) }) {
                    Image(systemName: "arrow.clockwise")
                }
                .buttonStyle(.plain)
            }
        }
        
        ToolbarItem(placement: .navigationBarLeading) {
            if let collection = collection {
                Button(action: { showFilter.toggle() }) {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                        .symbolVariant(collection.filterRaw != CollectionEntityFilter.all.rawValue ? .fill : .none)
                }
                .buttonStyle(.plain)
                .actionSheet(isPresented: $showFilter) {
                    ActionSheet(title: Text("Change Filter"), buttons: [
                        .default(
                            Text("All"),
                            action: {
//                                DataManager.shared.updateCollection(collection: collection, newFilterState: .all)
                            }),
                        .default(
                            Text("Only Read"),
                            action: {
//                                DataManager.shared.updateCollection(collection: collection, newFilterState: .read)
                            }),
                        .default(
                            Text("Only Unread"),
                            action: {
//                                DataManager.shared.updateCollection(collection: collection, newFilterState: .unread)
                            }),
                        .cancel()
                    ])
                }
            }
        }
    }
}
