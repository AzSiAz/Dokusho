//
//  FilteredCollectionPage.swift
//  Dokusho
//
//  Created by Stef on 29/09/2021.
//

import SwiftUI

struct FilteredCollectionPage: View {
    @FetchRequest var mangas: FetchedResults<MangaEntity>
    
    @ObservedObject var collection: CollectionEntity
    @Binding var selectedManga: MangaEntity?
    
    var columns: [GridItem] = [GridItem(.adaptive(minimum: 120, maximum: 120))]
    
    init(collection: CollectionEntity, selectedManga: Binding<MangaEntity?>, searchTerm: String) {
        self.collection = collection
        self._selectedManga = selectedManga
        self._mangas = .init(sortDescriptors: [MangaEntity.lastUpdate], predicate: MangaEntity.collectionPredicate(collection: collection, searchTerm: searchTerm), animation: .easeIn)
    }
    
    var body: some View {
        LazyVGrid(columns: columns) {
            ForEach(mangas) { manga in
                MangaCardView(manga: manga)
                    .onTapGesture { selectedManga = manga }
            }
        }
        .navigationTitle("\(collection.name ?? "No name") (\(mangas.count))")
        .navigationBarTitleDisplayMode(.automatic)
    }
}
