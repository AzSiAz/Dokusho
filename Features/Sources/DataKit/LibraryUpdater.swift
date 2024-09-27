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

@MainActor
public class LibraryUpdater: ObservableObject {
    public static let shared = LibraryUpdater()
    
    public struct RefreshStatus: Sendable {
        public var isRefreshing: Bool
        public var refreshProgress: Double
        public var refreshCount: Double
        public var refreshTitle: String
        public var collectionId: MangaCollection.ID
    }
    
    public struct RefreshData : Sendable {
        public var source: Source
        public var toRefresh: RefreshManga
    }

    private let database = AppDatabase.shared.database
    private var refreshStatus: [MangaCollection.ID: Bool] = [:]
    
    public func refreshCollection(collection: MangaCollection, onlyAllRead: Bool = true) async throws {
        guard refreshStatus[collection.id] == nil else { return }

        await MainActor.run {
            UIApplication.shared.isIdleTimerDisabled = true
        }
        
        updateRefreshStatus(collectionID: collection.id, refreshing: true)

        let data = try await database.read { [collection] db in
            try Manga.fetchForUpdate(db, collectionId: collection.id, onlyAllRead: onlyAllRead)
        }
        print("---------------------Fetching--------------------------")

        if data.count != 0 {
            try await withThrowingTaskGroup(of: RefreshData.self) { group in
                for row in data {
                    guard let source = row.scraper.asSource() else { throw "Source not found from scraper with id: \(row.scraper.id)" }

                    _ = group.addTaskUnlessCancelled(priority: .background) {
                        return .init(source: source, toRefresh: row)
                    }
                }
                
                for try await data in group {
                    await Task.yield()

                    do {
                        let mangaSource = try await data.source.fetchMangaDetail(id: data.toRefresh.mangaId)

                        let _ = try await database.write { db in
                            try Manga.updateFromSource(db: db, scraper: data.toRefresh.scraper, data: mangaSource)
                        }
                        
                        await Task.yield()
                    } catch (let error) {
                        print(error)
                        updateRefreshStatus(collectionID: collection.id, refreshing: false)
                    }
                }
            }
            
            print("---------------------Fetched--------------------------")
            
            self.updateRefreshStatus(collectionID: collection.id, refreshing: nil)
            await MainActor.run {
                UIApplication.shared.isIdleTimerDisabled = false
            }
        }

    }
    
    @MainActor
    public func updateRefreshStatus(collectionID: MangaCollection.ID, refreshing: Bool? = nil) {
        self.refreshStatus[collectionID] = refreshing
    }
}
