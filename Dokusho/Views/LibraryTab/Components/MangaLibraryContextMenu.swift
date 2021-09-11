//
//  MangaLibraryContextMenu.swift
//  Dokusho
//
//  Created by Stephan Deumier on 04/07/2021.
//

import SwiftUI

struct MangaLibraryContextMenu: View {    
    var count: Int
    var manga: MangaEntity
    
    init(manga: MangaEntity, count: Int) {
        self.manga = manga
        self.count = count
    }

    var body: some View {
        if count != 0 {
            Button(action: {
//                Task { await dataManager.markChaptersAllAs(for: manga, status: .read) }
            }) {
                Text("Mark as read")
            }
        }
        
        if count == 0 {
            Button(action: {
//                Task { await dataManager.markChaptersAllAs(for: manga, status: .unread) }
            }) {
                Text("Mark as unread")
            }
        }
    }
}
