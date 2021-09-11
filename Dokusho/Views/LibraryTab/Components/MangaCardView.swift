//
//  MangaCardView.swift
//  MangaCardView
//
//  Created by Stephan Deumier on 02/08/2021.
//

import SwiftUI

struct MangaCardView: View {
    @ObservedObject var manga: MangaEntity
    
    var count: Int { manga.chapters?.filter({ $0.isUnread }).count ?? 0 }
    
    var body: some View {
        ImageWithTextOver(title: manga.title!, imageUrl: manga.cover?.absoluteString ?? "")
            .frame(height: 180)
//            .overlay(alignment: .topTrailing) { MangaUnreadCount(count: count) }
//            .contextMenu { MangaLibraryContextMenu(manga: manga, count: count) }
            .frame(height: 180)
    }
}
