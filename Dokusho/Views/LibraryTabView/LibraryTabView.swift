//
//  LibraryView.swift
//  Dokusho
//
//  Created by Stephan Deumier on 31/05/2021.
//

import SwiftUI
import SwiftUIX

struct LibraryTabView: View {
    @FetchRequest(sortDescriptors: [CollectionEntity.positionOrder], predicate: nil, animation: .default)
    var collections: FetchedResults<CollectionEntity>

    @StateObject var vm: LibraryVM = .init()
    
    var body: some View {
        NavigationView {
            List {
                ForEach(collections) { collection in
                    NavigationLink(destination: CollectionPage(collection: collection)) {
                        Label("\(collection.getName()) (\(collection.mangas?.count ?? 0))", systemImage: "square.grid.2x2")
                    }
                }
            }
            .toolbar(content: { AddButton(onTapGesture: { print("test") }) })
            .navigationTitle("Collections")
        }
    }
}

struct CollectionPage: View {
    @ObservedObject var collection: CollectionEntity
    @FetchRequest var mangas: FetchedResults<MangaEntity>
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
            MangaDetailView(mangaId: manga.mangaId!, src: Int(manga.source!.sourceId))
        })
        .toolbar { LibraryToolbarView(collection: collection, showFilter: $showFilter) }
        .navigationTitle("\(collection.name ?? "No name") (\(mangas.count))")
        .navigationBarTitleDisplayMode(.inline)
    }
}
