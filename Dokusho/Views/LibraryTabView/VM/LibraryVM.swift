//
//  LibraryVM.swift
//  Dokusho (iOS)
//
//  Created by Stephan Deumier on 22/06/2021.
//

import Foundation
import SwiftUI
import CoreData
import MangaScraper
import OSLog

class LibraryVM: ObservableObject {
    struct RefreshStatus {
        var isRefreshing: Bool
        var refreshProgress: Int
        var refreshCount: Int
        var refreshTitle: String
    }
    
    struct RefreshManga {
        var source: Source
        var manga: Manga
        var scraper: Scraper
    }

    private let database = AppDatabase.shared.database
    var collection: MangaCollection

    @Published var searchTerm = ""
    @Published var showFilter = false
    @Published var collectionFilter: MangaCollectionFilter
    @Published var collectionOrderField: MangaCollectionOrder.Field
    @Published var collectionOrderDirection: MangaCollectionOrder.Direction
    @Published var refreshStatus: RefreshStatus?
    
    init(collection: MangaCollection) {
        self.collection = collection
        collectionFilter = collection.filter
        collectionOrderField = collection.order.field
        collectionOrderDirection = collection.order.direction
    }
    
    func refreshCollection() async throws {
        var status = RefreshStatus(isRefreshing: true, refreshProgress: 0, refreshCount: 1, refreshTitle: "Refreshing...")
        
        await updateRefreshStatus(status)
        
        let mangas = try await database.read { db in
            try Manga.all().forCollectionId(self.collection.id).fetchAll(db)
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
    
    func updateCollectionFilter(newFilter: MangaCollectionFilter) {
        do {
            try database.write { db in
                guard var foundCollection = try MangaCollection.fetchOne(db, id: collection.id) else { return }
                print(foundCollection)
                foundCollection.filter = newFilter
                print(foundCollection)

                try foundCollection.save(db)
            }
        } catch(let err) {
            print(err)
        }
    }
    
    func updateCollectionOrder(direction: MangaCollectionOrder.Direction? = nil, field: MangaCollectionOrder.Field? = nil) {
        do {
            try database.write { db in
                guard var foundCollection = try MangaCollection.fetchOne(db, id: collection.id) else { return }
                if let direction = direction { foundCollection.order.direction = direction }
                if let field = field { foundCollection.order.field = field }

                try foundCollection.save(db)
            }
        } catch(let err) {
            print(err)
        }
    }
}
