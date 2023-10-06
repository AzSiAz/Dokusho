//
//  MangaLibraryContextMenu.swift
//  Dokusho
//
//  Created by Stephan Deumier on 04/07/2021.
//

import SwiftUI
import DataKit

public struct MangaLibraryContextMenu: View {
    @Environment(\.appDatabase) var appDB

    var manga: PartialManga
    var count: Int
    
    public init(manga: PartialManga, count: Int) {
        self.manga = manga
        self.count = count
    }

    public var body: some View {
        if count != 0 {
            Button(action: { markAllChapterAs(newSatus: .read) }) {
                Text("Mark as read")
            }
        }
        
        if count == 0 {
            Button(action: { markAllChapterAs(newSatus: .unread) }) {
                Text("Mark as unread")
            }
        }
    }
    
    func markAllChapterAs(newSatus: ChapterStatus) {
        try? appDB.database.write { db in
            try MangaChapterDB.markAllAs(newStatus: newSatus, db: db, mangaId: manga.id)
        }
    }
}
