//
//  MangaLibraryContextMenu.swift
//  Dokusho
//
//  Created by Stephan Deumier on 04/07/2021.
//

import SwiftUI
import DataKit

public struct MangaLibraryContextMenu: View {
    var manga: Serie
    var count: Int
    
    public init(manga: Serie, count: Int) {
        self.manga = manga
        self.count = count
    }

    public var body: some View {
        if count != 0 {
            Button(action: { markAllChapterAsRead() }) {
                Text("Mark as read")
            }
        }
        
        if count == 0 {
            Button(action: { markAllChapterAsUnRead() }) {
                Text("Mark as unread")
            }
        }
    }
    
    func markAllChapterAsRead() {
//        try? appDB.database.write { db in
//            try MangaChapterDB.markAllAs(newStatus: newSatus, db: db, mangaId: manga.id)
//        }
    }
    
    func markAllChapterAsUnRead() {
//        try? appDB.database.write { db in
//            try MangaChapterDB.markAllAs(newStatus: newSatus, db: db, mangaId: manga.id)
//        }
    }
}
