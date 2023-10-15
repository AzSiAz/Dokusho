//
//  ByGenreListPage.swift
//  Dokusho
//
//  Created by Stef on 04/10/2021.
//

import SwiftUI
import GRDBQuery
import DataKit
import DynamicCollection

public struct SeriesByGenreListPage: View {
//    @GRDBQuery.Query(DistinctMangaGenreRequest()) var genres: [GenreWithMangaCount]
    
    public init() {}

    public var body: some View {
//        List(genres) { genre in
//            NavigationLink(destination: MangaInCollectionForGenre(genre: genre.genre, inModal: false)) {
//                Text(genre.genre)
//                    .badge("\(genre.mangaCount)")
//            }
//        }
//        .navigationTitle("By Genres")
//        .navigationBarTitleDisplayMode(.inline)
        EmptyView()
    }
}
