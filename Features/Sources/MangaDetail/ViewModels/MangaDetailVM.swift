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
import DataKit

@Observable
public class MangaDetailVM {
    @ObservationIgnored
    private let database = AppDatabase.shared.database
    
    @ObservationIgnored
    let scraper: Scraper
    @ObservationIgnored
    let mangaId: String
    
    var error = false
    var showMoreDesc = false
    var addToCollection = false
    var refreshing = false
    var selectedChapter: MangaChapter?
    
    public init(for scraper: Scraper, mangaId: String) {
        self.scraper = scraper
        self.mangaId = mangaId
    }

    @MainActor
    func update() async {
        defer {
            self.refreshing = false
        }

        do {
            guard let source = scraper.asSource() else { throw "Source Not found" }

            let sourceManga = try await source.fetchMangaDetail(id: mangaId)
            
            try _ = await database.write { db in
                try Manga.updateFromSource(db: db, scraper: self.scraper, data: sourceManga)
            }
        } catch {
            print(error)
            self.error = true
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
    
    func updateMangaInCollection(data: MangaWithDetail, _ collectionId: MangaCollection.ID? = nil) {
        do {
            try database.write { db in
                try Manga.updateCollection(id: data.manga.id, collectionId: collectionId, db)
            }
        } catch {
            withAnimation {
                self.error = true
            }
        }
    }
}
