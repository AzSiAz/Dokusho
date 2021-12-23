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
    
    @MainActor
    func update() async {
        withAnimation {
            self.error = false
            self.refreshing = true
        }

        do {
            guard let sourceManga = try? await scraper.asSource()?.fetchMangaDetail(id: mangaId) else { throw "Error fetch manga detail" }
            if var manga = data?.manga {
                manga.updateFromSource(from: sourceManga)
                
                try database.write { db in
                    try manga.save(db)

                    // TODO: Export this to correct place
                    for info in sourceManga.chapters.enumerated() {
                        let chapter = MangaChapter(from: info.element, position: info.offset, mangaId: manga.id, scraperId: scraper.id)
                        try chapter.save(db)
                    }
                }
            } else {
                try database.write { db in
                    var manga = Manga(from: sourceManga, sourceId: scraper.id)
                    try manga.save(db)

                    // TODO: Export this to correct place
                    for info in sourceManga.chapters.enumerated() {
                        let chapter = MangaChapter(from: info.element, position: info.offset, mangaId: manga.id, scraperId: scraper.id)
                        try chapter.save(db)
                    }
                }
            }

            try database.read { db in
                try withAnimation {
                    data = try Manga.fetchMangaWithDetail(for: mangaId, in: scraper.id, db)
                    self.refreshing = false
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
        } catch(let err) {
            print(err)
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
