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

public class LibraryUpdater: ObservableObject {
    public static let shared = LibraryUpdater()
    
    public struct RefreshStatus {
        public var isRefreshing: Bool
        public var refreshProgress: Double
        public var refreshCount: Double
        public var refreshTitle: String
        public var collectionId: MangaCollection.ID
    }
    
    public struct RefreshData {
        public var source: Source
        public var toRefresh: RefreshManga
    }

    private let database = AppDatabase.shared.database

    @Published public var refreshStatus: RefreshStatus?
    
    public func refreshCollection(collection: MangaCollection, onlyAllRead: Bool = true) async throws {
        defer {
            Task {
                await self.updateRefreshStatus()
            }
        }
        
        guard refreshStatus == nil else { return }

        var status = RefreshStatus(isRefreshing: true, refreshProgress: 0, refreshCount: 1, refreshTitle: "Refreshing...", collectionId: collection.id)
        
        await updateRefreshStatus(status)
        
        let data = try await database.read { db in
            try Manga.fetchForUpdate(db, collectionId: collection.id, onlyAllRead: onlyAllRead)
        }
        
        status.refreshCount = Double(data.count)
        await updateRefreshStatus(status)
        
        if data.count != 0 {
            try await withThrowingTaskGroup(of: RefreshData.self) { group in
                for row in data {
                    guard let source = row.scraper.asSource() else { throw "Source not found from scraper with id: \(row.scraper.id)" }

                    _ = group.addTaskUnlessCancelled(priority: .background) {
                        return .init(source: source, toRefresh: row)
                    }
                }
                
                for try await data in group {
                    do {
                        status.refreshTitle = "Updating: \(data.toRefresh.title)"
                        await updateRefreshStatus(status)

                        let mangaSource = try await data.source.fetchMangaDetail(id: data.toRefresh.mangaId)

                        let _ = try await database.write { db in
                            try Manga.updateFromSource(db: db, scraper: data.toRefresh.scraper, data: mangaSource)
                        }
                        
                        status.refreshProgress+=1
                        await updateRefreshStatus(status)
                    } catch (let error) {
                        print(error)

                        status.refreshProgress+=1
                        await updateRefreshStatus(status)
                    }
                }
            }
        }

    }
    
    @MainActor
    public func updateRefreshStatus(_ newStatus: RefreshStatus? = nil) {
        self.refreshStatus = newStatus
    }
}
