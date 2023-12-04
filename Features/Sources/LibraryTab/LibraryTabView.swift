//
//  LibraryView.swift
//  Dokusho
//
//  Created by Stephan Deumier on 31/05/2021.
//

import SwiftUI
import SerieScraper
import DataKit
import SharedUI
import SerieDetail

public struct LibraryTabView: View {
    @Environment(LibraryUpdater.self) private var libraryRefresh
    
    @Harmony var harmony

    @Query(AllSerieCollectionWithCountRequest()) var collections

    @State var editMode: EditMode = .inactive
    @State var newCollectionName = ""
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            List {
                Section("User Collection") {
                    ForEach(collections) { info in
                        NavigationLink(value: info.serieCollection) {
                            Label(info.serieCollection.name, systemImage: "square.grid.2x2")
                                .badge("\(info.serieCount)")
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
                    NavigationLink(destination: SeriesByGenreListPage()) {
                        Text("By Genres")
                    }
                    
                    NavigationLink(destination: SeriesByScraperListPage()) {
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
            .navigationDestination(for: DetailedSerieInList.self) { data in
                SerieDetailScreen(serieID: data.serie.internalID, scraperID: data.scraper.id)
            }
            .navigationDestination(for: SerieCollection.self) { data in
                SerieCollectionPage(collection: data)
            }
        }
        .navigationViewStyle(.stack)
    }
    
    func saveNewCollection() {
        guard !newCollectionName.isEmpty else { return }
        let lastPosition = (collections.last?.serieCollection.position ?? 0) + 1
        let collection = SerieCollection(name: newCollectionName, position: lastPosition)
        newCollectionName = ""

        Task { [collection] in
            try await harmony.save(record: collection)
        }
    }
    
    func onDelete(_ offsets: IndexSet) {
        let toDelete = offsets.map { collections[$0].serieCollection }
        
        Task { [toDelete] in
            try await harmony.delete(records: toDelete)
        }
    }
    
    func onMove(_ offsets: IndexSet, _ position: Int) {
//        try? appDB.database.write { db in
//            var revisedItems: [MangaCollectionDB] = collections.map{ $0.mangaCollection }
//
////            change the order of the items in the array
//            revisedItems.move(fromOffsets: offsets, toOffset: position)
//
////            update the position attribute in revisedItems to
////            persist the new order. This is done in reverse order
////            to minimize changes to the indices.
//            for reverseIndex in stride(from: revisedItems.count - 1, through: 0, by: -1) {
//                revisedItems[reverseIndex].position = reverseIndex
//                try revisedItems[reverseIndex].save(db)
//            }
//        }
    }
}
