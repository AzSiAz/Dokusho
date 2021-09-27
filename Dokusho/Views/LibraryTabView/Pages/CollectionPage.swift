//
//  ManageCollectionsModal.swift
//  Dokusho (iOS)
//
//  Created by Stephan Deumier on 26/06/2021.
//

import SwiftUI

struct CollectionPage: View {
    @FetchRequest var mangas: FetchedResults<MangaEntity>

    @ObservedObject var collection: CollectionEntity
    @State var selectedManga: MangaEntity?
    @State var showFilter = false
    
    var columns: [GridItem] = [GridItem(.adaptive(minimum: 120, maximum: 120))]
    
    init(collection: CollectionEntity) {
        self._collection = .init(wrappedValue: collection)
        self._mangas = .init(sortDescriptors: [MangaEntity.lastUpdate], predicate: MangaEntity.collectionPredicate(collection: collection), animation: .easeIn)
    }
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns) {
                ForEach(mangas) { manga in
                    MangaCardView(manga: manga)
                        .onTapGesture { selectedManga = manga }
                }
            }
        }
        .sheetSizeAware(item: $selectedManga, content: { manga in
            MangaDetailView(mangaId: manga.mangaId!, src: manga.sourceId)
        })
        .toolbar { LibraryToolbarView(collection: collection, showFilter: $showFilter) }
        .navigationTitle("\(collection.name ?? "No name") (\(mangas.count))")
        .navigationBarTitleDisplayMode(.inline)
    }
}
