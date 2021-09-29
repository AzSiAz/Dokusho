//
//  ManageCollectionsModal.swift
//  Dokusho (iOS)
//
//  Created by Stephan Deumier on 26/06/2021.
//

import SwiftUI

struct CollectionPage: View {
    

    @ObservedObject var collection: CollectionEntity
    @State var selectedManga: MangaEntity?
    @State var showFilter = false
    
    @State var searchTerm = ""
    
    init(collection: CollectionEntity) {
        self._collection = .init(wrappedValue: collection)
    }
    
    var body: some View {
        ScrollView {
            FilteredCollectionPage(collection: collection, selectedManga: $selectedManga, searchTerm: searchTerm)
        }
        .sheetSizeAware(item: $selectedManga, content: { manga in
            MangaDetailView(mangaId: manga.mangaId!, src: manga.sourceId)
        })
        .searchable(text: $searchTerm)
        .toolbar { LibraryToolbarView(collection: collection, showFilter: $showFilter) }
    }
}
