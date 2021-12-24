//
//  FilteredCollectionPage.swift
//  Dokusho
//
//  Created by Stef on 29/09/2021.
//

import SwiftUI
import GRDBQuery

struct FilteredCollectionPage: View {
    @Query<DetailedMangaInListRequest> var list: [DetailedMangaInList]
    @Binding var selectedManga: DetailedMangaInList?

    var collection: MangaCollection
    var columns: [GridItem] = [GridItem(.adaptive(minimum: 120, maximum: 120))]
    
    init(collection: MangaCollection, selectedManga: Binding<DetailedMangaInList?>, searchTerm: String) {
        self.collection = collection
        _selectedManga = selectedManga
        _list = Query(DetailedMangaInListRequest(requestType: .forCollection(collection: collection, searchTerm: searchTerm)))
    }
    
    var body: some View {
        LazyVGrid(columns: columns) {
            ForEach(list) { data in
                MangaCardView(manga: data.manga, count: data.unreadChapterCount)
                    .onTapGesture { selectedManga = data }
            }
        }
        .navigationTitle("\(collection.name) (\(list.count))")
        .navigationBarTitleDisplayMode(.automatic)
    }
}
