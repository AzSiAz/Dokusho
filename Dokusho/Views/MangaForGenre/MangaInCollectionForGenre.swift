//
//  MangaInCollectionForGenre.swift
//  Dokusho
//
//  Created by Stef on 04/10/2021.
//

import SwiftUI

struct MangaInCollectionForGenre: View {
    @Environment(\.dismiss) var dismiss
    @FetchRequest var mangas: FetchedResults<MangaEntity>
    @ObservedObject var genre: GenreEntity
    @State var selectedManga: MangaEntity?
    
    var showDismiss: Bool
    
    var columns: [GridItem] = [GridItem(.adaptive(minimum: 120, maximum: 120))]
    
    init(genre: GenreEntity, showDismiss: Bool = true) {
        self.showDismiss = showDismiss
        self.genre = genre

        self._mangas = .init(sortDescriptors: [MangaEntity.nameOrder], predicate: MangaEntity.forGenres(genre: genre), animation: .easeIn)
    }
    
    var body: some View {
        if showDismiss {
            NavigationView {
                content
            }
        } else {
            content
        }
    }
    
    
    @ViewBuilder
    var content: some View {
        ScrollView {
            LazyVGrid(columns: columns) {
                ForEach(mangas) { manga in
                    MangaCardView(manga: manga)
                        .onTapGesture { selectedManga = manga }
                }
            }
        }
        .navigationTitle("\(genre.name ?? "No name") (\(mangas.count))")
        .navigationBarTitleDisplayMode(.automatic)
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                if showDismiss {
                    Button(action: dismiss.callAsFunction) {
                        Image(systemSymbol: .xmark)
                    }
                }
            }
        }
        .sheetSizeAware(item: $selectedManga, content: { manga in
            MangaDetailView(mangaId: manga.mangaId!, src: manga.sourceId, isInCollectionPage: true)
        })
    }
}
