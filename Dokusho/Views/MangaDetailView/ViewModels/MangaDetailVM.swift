//
//  MangaDetailVM.swift
//  Dokusho (iOS)
//
//  Created by Stephan Deumier on 14/06/2021.
//

import Foundation
import SwiftUI
import MangaScraper
import GRDB

@MainActor
class MangaDetailVM: ObservableObject {
    private let database = AppDatabase.shared.database
    
    let scraper: Scraper
    let mangaId: String
    let showDismiss: Bool
    
    @Published var error = false
    @Published var showMoreDesc = false
    @Published var addToCollection = false
    @Published var refreshing = false
    @Published var selectedChapter: MangaChapter?
    @Published var selectedGenre: String?
    @Published var data: MangaWithDetail?
    
    init(for scraper: Scraper, mangaId: String, showDismiss: Bool) {
        self.scraper = scraper
        self.mangaId = mangaId
        self.showDismiss = showDismiss
        
        try? database.read { db in
            try withAnimation {
                data = try Manga.fetchMangaWithDetail(for: mangaId, in: scraper.id, db)
            }
        }
    }
    
    func fetchManga() async {
        if data == nil { await update() }
    }

    func update() async {
        withAnimation {
            self.error = false
            self.refreshing = true
        }

        do {
            guard let source = scraper.asSource() else { throw "Source Not found" }
            let sourceManga = try await source.fetchMangaDetail(id: mangaId)
            
            try _ = await database.write { db in
                try Manga.updateFromSource(db: db, scraper: self.scraper, data: sourceManga)
            }

            try await database.read { db in
                let updated = try Manga.fetchMangaWithDetail(for: self.mangaId, in: self.scraper.id, db)
                
                DispatchQueue.main.async {
                    withAnimation {
                        self.data = updated
                        self.refreshing = false
                    }
                }
            }
        } catch {
            withAnimation {
                self.error = true
                self.refreshing = false
            }
        }
    }
    
    func getMangaURL() -> URL {
        return scraper.asSource()?.mangaUrl(mangaId: self.mangaId) ?? URL(string: "")!
    }
    
    func getSourceName() -> String {
        return scraper.name
    }
    
    // TODO: Rework reset cache to avoid deleting chapter read/unread info
    func resetCache() async {}
    
    func insertMangaInCollection(_ collection: MangaCollection) {
        guard var manga = data?.manga else { return }

        do {
            try database.write { db in
                manga.mangaCollectionId = collection.id
                try manga.save(db)
                
                try withAnimation {
                    data = try Manga.fetchMangaWithDetail(for: mangaId, in: scraper.id, db)
                }
            }
        } catch {
            withAnimation {
                self.error = true
            }
        }
    }
    
    func removeMangaFromCollection() {
        guard var manga = data?.manga else { return }

        do {
            try database.write { db in
                manga.mangaCollectionId = nil
                try manga.save(db)
                
                try withAnimation {
                    data = try Manga.fetchMangaWithDetail(for: mangaId, in: scraper.id, db)
                }
            }
        } catch(let err) {
            print(err)
            withAnimation {
                self.error = true
            }
        }
    }
}
