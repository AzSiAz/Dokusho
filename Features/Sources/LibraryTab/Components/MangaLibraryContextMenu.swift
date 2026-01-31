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
    var scraper: Scraper?
    var count: Int
    var onMigrate: (() -> Void)?

    public init(manga: PartialManga, count: Int) {
        self.manga = manga
        self.count = count
        self.scraper = nil
        self.onMigrate = nil
    }

    public init(manga: PartialManga, scraper: Scraper, count: Int, onMigrate: @escaping () -> Void) {
        self.manga = manga
        self.scraper = scraper
        self.count = count
        self.onMigrate = onMigrate
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

        if let onMigrate = onMigrate {
            Divider()

            Button(action: onMigrate) {
                Label("Migrate Series", systemImage: "arrow.triangle.swap")
            }
        }
    }

    func markAllChapterAs(newSatus: ChapterStatus) {
        try? appDB.database.write { db in
            try MangaChapter.markAllAs(newStatus: newSatus, db: db, mangaId: manga.id)
        }
    }
}
