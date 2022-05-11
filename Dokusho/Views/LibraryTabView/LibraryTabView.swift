//
//  LibraryView.swift
//  Dokusho
//
//  Created by Stephan Deumier on 31/05/2021.
//

import SwiftUI
import MangaScraper
import GRDBQuery
import DataKit

struct LibraryTabView: View {
    @Environment(\.appDatabase) var appDB

    @Query(DetailedMangaCollectionRequest()) var collections

    @State var editMode: EditMode = .inactive
    @State var newCollectionName = ""
    
    var body: some View {
        NavigationView {
            List {
                Section("User Collection") {
                    ForEach(collections) { info in
                        NavigationLink(destination: CollectionPage(collection: info.mangaCollection)) {
                            Label(info.mangaCollection.name, systemImage: "square.grid.2x2")
                                .badge("\(info.mangaCount)")
                                .padding(.vertical)
                        }
                    }
                    .onDelete(perform: onDelete)
                    .onMove(perform: onMove)
                    
                    if editMode.isEditing {
                        TextField("New collection name", text: $newCollectionName)
                            .padding(.vertical)
                            .submitLabel(.done)
                            .onSubmit(saveNewCollection)
                    }
                }
                
                Section("Dynamic Collection") {
                    NavigationLink(destination: ByGenreListPage()) {
                        Text("By Genres")
                    }
                    
                    NavigationLink(destination: BySourceListPage()) {
                        Text("By Source List")
                    }
                }
            }
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    EditButton()
                }
            }
            .navigationTitle("Collections")
            .environment(\.editMode, $editMode)
            .mirrorAppearanceState(to: $collections.isAutoupdating)
        }
    }
    
    func saveNewCollection() {
        guard !newCollectionName.isEmpty else { return }
        let lastPosition = (collections.last?.mangaCollection.position ?? 0) + 1
        
        do {
            try appDB.database.write { db in
                let collection = MangaCollection(id: UUID(), name: newCollectionName, position: lastPosition)
                try collection.save(db)
            }
        } catch(let err) {
            print(err)
        }
        
        newCollectionName = ""
    }
    
    func onDelete(_ offsets: IndexSet) {
        offsets
            .map { collections[$0] }
            .forEach { collection in
                do {
                    let _ = try appDB.database.write { db in
                        try collection.mangaCollection.delete(db)
                    }
                } catch(let err) {
                    print(err)
                }
            }
    }
    
    func onMove(_ offsets: IndexSet, _ position: Int) {
        try? appDB.database.write { db in
            var revisedItems: [MangaCollection] = collections.map{ $0.mangaCollection }

//            change the order of the items in the array
            revisedItems.move(fromOffsets: offsets, toOffset: position)

//            update the position attribute in revisedItems to
//            persist the new order. This is done in reverse order
//            to minimize changes to the indices.
            for reverseIndex in stride(from: revisedItems.count - 1, through: 0, by: -1) {
                revisedItems[reverseIndex].position = reverseIndex
                try revisedItems[reverseIndex].save(db)
            }
        }
    }
}
