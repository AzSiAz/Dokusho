//
//  MangaLibraryContextMenu.swift
//  Dokusho
//
//  Created by Stephan Deumier on 04/07/2021.
//

import SwiftUI

struct MangaLibraryContextMenu: View {
    var fetchRequest: FetchRequest<MangaChapter>
    var count: Int { fetchRequest.wrappedValue.count }
    var vm: LibraryVM
    var manga: Manga
    
    init(manga: Manga, vm: LibraryVM) {
        self.vm = vm
        self.manga = manga
        self.fetchRequest = FetchRequest<MangaChapter>(fetchRequest: MangaChapter.fetchChaptersForManga(mangaId: manga.id!, status: .unread))
    }

    var body: some View {
        if count != 0 {
            Button(action: { vm.markChaptersMangaAs(for: manga, status: .read) }) {
                Text("Mark as read")
            }
        }
        
        if count == 0 {
            Button(action: { vm.markChaptersMangaAs(for: manga, status: .unread) }) {
                Text("Mark as unread")
            }
        }
    }
}
