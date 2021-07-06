//
//  MangaLibraryContextMenu.swift
//  Dokusho
//
//  Created by Stephan Deumier on 04/07/2021.
//

import SwiftUI

struct MangaLibraryContextMenu: View {
    var dataManager = DataManager.shared
    
    var count: Int
    var vm: LibraryVM
    var manga: Manga
    
    init(manga: Manga, vm: LibraryVM, count: Int) {
        self.vm = vm
        self.manga = manga
        self.count = count
    }

    var body: some View {
        if count != 0 {
            Button(action: { dataManager.markChaptersAllAs(for: manga, status: .read) }) {
                Text("Mark as read")
            }
        }
        
        if count == 0 {
            Button(action: { dataManager.markChaptersAllAs(for: manga, status: .unread) }) {
                Text("Mark as unread")
            }
        }
    }
}
