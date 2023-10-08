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
import Common
import Observation

@Observable
public class LibraryUpdater {
    public static let shared = LibraryUpdater()

    public struct RefreshStatus {
        public var isRefreshing: Bool
        public var refreshProgress: Double
        public var refreshCount: Double
        public var refreshTitle: String
        public var collectionId: MangaCollectionDB.ID
    }
    
    public struct RefreshData {
        public var source: Source
        public var toRefresh: RefreshManga
    }

//    private let database = AppDatabase.shared.database
    public var refreshStatus: [MangaCollectionDB.ID: Bool] = [:]
    
    private init() {}
    
    public func refreshCollection(collection: MangaCollectionDB, onlyAllRead: Bool = true) async throws {
        guard refreshStatus[collection.id] == nil else { return }

        await MainActor.run {
            UIApplication.shared.isIdleTimerDisabled = true
        }
        
        await updateRefreshStatus(collectionID: collection.id, refreshing: true)

        let data = [Manga]()
//        try await database.read { db in
//            try MangaDB.fetchForUpdate(db, collectionId: collection.id, onlyAllRead: onlyAllRead)
//        }
        
        Logger.libraryUpdater.debug("---------------------Fetching--------------------------")
        
        guard data.count != 0 else { return }

//        try await withThrowingTaskGroup(of: RefreshData.self) { group in
//            for row in data {
//                guard let source = ScraperService.shared.getSource(sourceId: row.scraperId) else { throw "Source not found from scraper with id: \(row.scraper.id)" }
//
//                _ = group.addTaskUnlessCancelled(priority: .background) {
//                    return RefreshData(source: source, toRefresh: row)
//                }
//            }
//            
//            for try await data in group {
//                await Task.yield()
//
//                do {
//                    let mangaSource = try await data.source.fetchMangaDetail(id: data.toRefresh.mangaId)
//
//                    let _ = try await database.write { db in
//                        try MangaDB.updateFromSource(db: db, scraper: data.toRefresh.scraper, data: mangaSource)
//                    }
//                    
//                    await Task.yield()
//                } catch (let error) {
//                    Logger.libraryUpdater.error("Error updating \(data.toRefresh.title): \(error)")
//                    await updateRefreshStatus(collectionID: collection.id, refreshing: false)
//                }
//            }
//        }
        
        Logger.libraryUpdater.debug("---------------------Fetched--------------------------")
        
        await self.updateRefreshStatus(collectionID: collection.id, refreshing: nil)

        await MainActor.run {
            UIApplication.shared.isIdleTimerDisabled = false
        }
    }
    
    @MainActor
    public func updateRefreshStatus(collectionID: MangaCollectionDB.ID, refreshing: Bool? = nil) {
        self.refreshStatus[collectionID] = refreshing
    }
}
