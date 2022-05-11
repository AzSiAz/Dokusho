//
//  LibraryVM.swift
//  Dokusho (iOS)
//
//  Created by Stephan Deumier on 22/06/2021.
//

import Foundation
import SwiftUI
import MangaScraper
import OSLog
import DataKit

class LibraryUpdater: ObservableObject {
    struct RefreshStatus {
        var isRefreshing: Bool
        var refreshProgress: Int
        var refreshCount: Int
        var refreshTitle: String
        var collectionId: MangaCollection.ID
    }
    
    struct RefreshManga {
        var source: Source
        var manga: Manga
        var scraper: Scraper
    }

    private let database = AppDatabase.shared.database

    @Published var refreshStatus: RefreshStatus?
    
    func refreshCollection(collection: MangaCollection) async throws {
        var status = RefreshStatus(isRefreshing: true, refreshProgress: 0, refreshCount: 1, refreshTitle: "Refreshing...", collectionId: collection.id)
        
        await updateRefreshStatus(status)
        
        let mangas = try await database.read { db in
            try Manga.all().forCollectionId(collection.id).fetchAll(db)
        }
        
        status.refreshCount = mangas.count
        await updateRefreshStatus(status)
        
        try await withThrowingTaskGroup(of: RefreshManga.self) { group in
            for manga in mangas {
                guard let scraperId = manga.scraperId else { throw "Manga without a scraper" }
                let scraper = try await database.read { try Scraper.fetchOne($0, sourceId: scraperId) }
                guard let source = scraper.asSource() else { throw "Source not found from scraper with id: \(scraperId)" }

                _ = group.addTaskUnlessCancelled(priority: .background) {
                    return .init(source: source, manga: manga, scraper: scraper)
                }
            }
            
            
            for try await data in group {
                status.refreshTitle = "Updating: \(data.manga.title)"
                await updateRefreshStatus(status)

                let mangaSource = try await data.source.fetchMangaDetail(id: data.manga.mangaId)

                let _ = try await database.write {
                    try Manga.updateFromSource(db: $0, scraper: data.scraper, data: mangaSource)
                }
                
                status.refreshProgress+=1
                await updateRefreshStatus(status)
            }
        }

        await updateRefreshStatus()
    }
    
    @MainActor
    func updateRefreshStatus(_ newStatus: RefreshStatus? = nil) {
        self.refreshStatus = newStatus
    }
}
