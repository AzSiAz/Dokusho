//
//  ByGenreListPage.swift
//  Dokusho
//
//  Created by Stef on 04/10/2021.
//

import SwiftUI
import DataKit
import DynamicCollection

public struct SeriesByGenreListPage: View {
    @Query(DistinctSerieGenreRequest()) var genres
    
    public init() {}

    public var body: some View {
        List(genres) { genre in
            NavigationLink(destination: SerieInCollectionForGenre(genre: genre.genre)) {
                Text(genre.genre)
                    .badge("\(genre.serieCount)")
            }
        }
        .navigationTitle("By Genres")
        .navigationBarTitleDisplayMode(.inline)
    }
}
