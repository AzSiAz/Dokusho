//
//  FilteredCollectionPage.swift
//  Dokusho
//
//  Created by Stef on 29/09/2021.
//

import SwiftUI
import GRDBQuery

struct FilteredCollectionPage: View {
    @Query<DetailedMangaInCollectionsRequest> var mangas: [DetailedMangaInCollections]
    @Binding var selectedManga: Manga?

    var collection: MangaCollection
    var columns: [GridItem] = [GridItem(.adaptive(minimum: 120, maximum: 120))]
    
    init(collection: MangaCollection, selectedManga: Binding<Manga?>, searchTerm: String) {
        self.collection = collection
        _selectedManga = selectedManga
        _mangas = Query(DetailedMangaInCollectionsRequest(requestType: .forCollection(collection: collection, searchTerm: searchTerm)))
    }
    
    var body: some View {
        LazyVGrid(columns: columns) {
            ForEach(mangas) { manga in
                MangaCardView(manga: manga.manga, count: manga.unreadChapterCount)
                    .onTapGesture { selectedManga = manga.manga }
            }
        }
        .navigationTitle("\(collection.name) (\(mangas.count))")
        .navigationBarTitleDisplayMode(.automatic)
    }
}
