//
//  ByGenreListPage.swift
//  Dokusho
//
//  Created by Stef on 04/10/2021.
//

import SwiftUI

struct ByGenreListPage: View {
    @FetchRequest<GenreEntity>(sortDescriptors: [GenreEntity.nameSort], animation: .easeIn) var genres
    
    var body: some View {
        List(genres) { genre in
            NavigationLink(destination: MangaInCollectionForGenre(genre: genre, showDismiss: false)) {
                Text("\(genre.name ?? "No Name") (\(genre.mangas?.count ?? 0))")
            }
        }
        .navigationTitle("By Genres")
        .navigationBarTitleDisplayMode(.inline)
    }
}
