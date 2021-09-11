//
//  MangaCollectionPage.swift
//  Dokusho
//
//  Created by Stephan Deumier on 02/07/2021.
//

import SwiftUI
import MangaScraper

struct MangaCollectionPage: View {
    @ObservedObject var collection: CollectionEntity
    @State var selectedManga: MangaEntity?
    
//    var fetchRequest: FetchRequest<MangaEntity>
//    var mangas: FetchedResults<MangaEntity> { fetchRequest.wrappedValue }

    var columns: [GridItem] = [GridItem(.adaptive(minimum: 120, maximum: 120))]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns) {
                ForEach(collection.mangas?.shuffled() ?? []) { manga in
                    MangaCardView(manga: manga)
                        .onTapGesture { selectedManga = manga }
                }
            }
        }
        .sheetSizeAware(item: $selectedManga, content: { manga in
            NavigationView {
                MangaDetailView(mangaId: manga.mangaId!, src: manga.source!)
            }
        })
        .navigationBarTitle("\(collection.name ?? "") (\(collection.mangas?.count ?? 0))", displayMode: .inline)
    }
}
