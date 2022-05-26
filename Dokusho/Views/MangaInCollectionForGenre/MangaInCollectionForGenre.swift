//
//  MangaInCollectionForGenre.swift
//  Dokusho
//
//  Created by Stef on 04/10/2021.
//

import SwiftUI
import GRDBQuery
import DataKit
import SharedUI

struct MangaInCollectionForGenre: View {
    @Environment(\.dismiss) var dismiss
    @Query<DetailedMangaInListRequest> var list: [DetailedMangaInList]

    @State var selectedManga: DetailedMangaInList?
    
    var genre: String
    var showDismiss: Bool
    var columns: [GridItem] = [GridItem(.adaptive(minimum: 130, maximum: 130))]
    
    init(genre: String, showDismiss: Bool = true) {
        self.showDismiss = showDismiss
        self.genre = genre
        _list = Query(DetailedMangaInListRequest(genre: genre))
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
                    NavigationLink(destination: MangaDetailView(mangaId: data.manga.mangaId, scraper: data.scraper)) {
                        MangaCard(title: data.manga.title, imageUrl: data.manga.cover.absoluteString, chapterCount: data.unreadChapterCount)
                            .mangaCardFrame()
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .navigationTitle("\(genre) (\(list.count))")
        .navigationBarTitleDisplayMode(.automatic)
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                if showDismiss {
                    Button(action: dismiss.callAsFunction) {
                        Image(systemName: "xmark")
                    }
                }
            }
        }
    }
}
