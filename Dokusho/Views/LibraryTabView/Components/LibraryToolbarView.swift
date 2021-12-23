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

    var body: some ToolbarContent {
//        TODO: Cancel task when I know how it work^^
//        ToolbarItem(placement: .navigationBarTrailing) {
//            AsyncButton(action: { /*vm.refreshLib(for: collection)*/ }) {
//                Image(systemName: "arrow.clockwise")
//            }
//            .buttonStyle(.plain)
//        }
        
        ToolbarItem(placement: .navigationBarTrailing) {
            Button(action: { showFilter.toggle() }) {
                Image(systemName: "line.3.horizontal.decrease.circle")
                    .symbolVariant(collection.filter == .onlyUnReadChapter ? .fill : .none)
            }
            .buttonStyle(.plain)
            .actionSheet(isPresented: $showFilter) {
                ActionSheet(title: Text("Change Filter"), buttons: [
                    .default(
                        Text("All"),
                        action: { updateCollectionFilter(newFilter: .all) }),
                    .default(
                        Text("Only Unread"),
                        action: { updateCollectionFilter(newFilter: .onlyUnReadChapter) }),
                    .cancel()
                ])
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
}
