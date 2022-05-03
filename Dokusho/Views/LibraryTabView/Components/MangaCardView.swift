//
//  MangaCardView.swift
//  MangaCardView
//
//  Created by Stephan Deumier on 02/08/2021.
//

import SwiftUI

struct MangaCardView: View {
    var manga: PartialManga
    var count: Int
    
    var body: some View {
        ImageWithTextOver(title: manga.title, imageUrl: manga.cover.absoluteString)
            .overlay(alignment: .topTrailing) { MangaUnreadCount(count: count) }
            .contextMenu { MangaLibraryContextMenu(manga: manga, count: count) }
            .frame(height: 180)
    }
}
