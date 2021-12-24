//
//  MangaInCollectionForGenre.swift
//  Dokusho
//
//  Created by Stef on 04/10/2021.
//

import SwiftUI
import GRDBQuery

struct MangaInCollectionForGenre: View {
    @Environment(\.dismiss) var dismiss
    @Query<DetailedMangaInListRequest> var list: [DetailedMangaInList]
    @State var selectedManga: DetailedMangaInList?
    
    var genre: String
    var showDismiss: Bool
    var columns: [GridItem] = [GridItem(.adaptive(minimum: 120, maximum: 120))]
    
    init(genre: String, showDismiss: Bool = true) {
        self.showDismiss = showDismiss
        self.genre = genre
        _list = Query(DetailedMangaInListRequest(requestType: .forGenre(genre: genre)))
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
                ForEach(list) { data in
                    MangaCardView(manga: data.manga, count: data.unreadChapterCount)
                        .onTapGesture { selectedManga = data }
                }
            }
        }
        .navigationTitle("\(genre) (\(list.count))")
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
        .sheetSizeAware(item: $selectedManga, content: { data in
            MangaDetailView(mangaId: data.manga.mangaId, scraper: data.scraper)
        })
    }
}
