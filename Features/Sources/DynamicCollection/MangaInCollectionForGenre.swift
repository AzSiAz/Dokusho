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
import MangaDetail

public struct MangaInCollectionForGenre: View {
    @Query<DetailedMangaInListRequest> var list: [DetailedMangaInList]

    @State var selectedManga: DetailedMangaInList?
    
    var inModal: Bool
    var genre: String
    
    public init(genre: String, inModal: Bool = true) {
        self.inModal = inModal
        self.genre = genre
        _list = Query(DetailedMangaInListRequest(requestType: .genre(genre: genre)))
    }
    
    public var body: some View {
        if inModal {
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
            MangaList(mangas: list) { data in
                NavigationLink(destination: MangaDetail(mangaId: data.manga.mangaId, scraper: data.scraper)) {
                    MangaCard(title: data.manga.title, imageUrl: data.manga.cover.absoluteString, chapterCount: data.unreadChapterCount)
                        .mangaCardFrame()
                }
                .buttonStyle(.plain)
            }
        }
        .navigationTitle("\(genre) (\(list.count))")
        .navigationBarTitleDisplayMode(.automatic)
    }
}
