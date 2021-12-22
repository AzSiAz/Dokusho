//
//  LibraryToolbarView.swift
//  LibraryToolbarView
//
//  Created by Stephan Deumier on 27/07/2021.
//

import SwiftUI

struct LibraryToolbarView: ToolbarContent {
    var collection: MangaCollection
    @Binding var showFilter: Bool

    var body: some ToolbarContent {
//        ToolbarItem(placement: .navigationBarTrailing) {
            // TODO: Cancel task when I know how it work^^
//            AsyncButton(action: { /*vm.refreshLib(for: collection)*/ }) {
//                Image(systemName: "arrow.clockwise")
//            }
//            .buttonStyle(.plain)
//        }
        
        ToolbarItem(placement: .navigationBarTrailing) {
//            if let collection = collection {
//                Button(action: { showFilter.toggle() }) {
//                    Image(systemName: "line.3.horizontal.decrease.circle")
//                        .symbolVariant(collection.filter.isNotAll() ? .fill : .none)
//                }
//                .buttonStyle(.plain)
//                .actionSheet(isPresented: $showFilter) {
//                    ActionSheet(title: Text("Change Filter"), buttons: [
//                        .default(
//                            Text("All"),
//                            action: { updateCollectionFilter(newFilter: .all) }),
//                        .default(
//                            Text("Only Read"),
//                            action: { updateCollectionFilter(newFilter: .read) }),
//                        .default(
//                            Text("Only Unread"),
//                            action: { updateCollectionFilter(newFilter: .unread) }),
//                        .cancel()
//                    ])
//                }
//            }
        }
    }
    
    func updateCollectionFilter(newFilter: CollectionEntityFilter) {
//        collection.filter = newFilter
//        try? collection.managedObjectContext?.save()
    }
}
