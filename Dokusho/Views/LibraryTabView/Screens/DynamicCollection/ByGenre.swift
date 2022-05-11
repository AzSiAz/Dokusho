//
//  ByGenreListPage.swift
//  Dokusho
//
//  Created by Stef on 04/10/2021.
//

import SwiftUI
import GRDBQuery
import DataKit

struct ByGenreListPage: View {
    @Query(DistinctMangaGenreRequest()) var genres: [GenreWithMangaCount]

    var body: some View {
        List(genres) { genre in
            NavigationLink(destination: MangaInCollectionForGenre(genre: genre.genre, showDismiss: false)) {
                Text(genre.genre)
                    .badge("\(genre.mangaCount)")
            }
        }
        .navigationTitle("By Genres")
        .navigationBarTitleDisplayMode(.inline)
    }
}
