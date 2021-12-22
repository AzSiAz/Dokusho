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
    @State var selectedManga: Manga?
    @State var showFilter = false
    
    @State var searchTerm = ""
    
    init(collection : MangaCollection) {
        _collection = Query(OneMangaCollectionRequest(collectionId: collection.id))
    }
    
    var body: some View {
        if let collection = collection {
            ScrollView {
                FilteredCollectionPage(collection: collection, selectedManga: $selectedManga, searchTerm: searchTerm)
            }
            .sheetSizeAware(item: $selectedManga, content: { manga in
                MangaDetailView(mangaId: manga.mangaId, src: manga.scraperId!, isInCollectionPage: true)
            })
            .searchable(text: $searchTerm)
            .toolbar { LibraryToolbarView(collection: collection, showFilter: $showFilter) }
        }
    }
}
