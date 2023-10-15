import Foundation
import Observation
import SerieScraper
import OSLog
import Common
import SwiftData

@Observable
public class LibraryUpdater {
    public static let shared = LibraryUpdater()

    public struct RefreshStatus {
        public var isRefreshing: Bool
        public var refreshProgress: Double
        public var refreshCount: Double
        public var refreshTitle: String
        public var collectionId: PersistentIdentifier
    }
    
    public struct RefreshData {
        public var source: Source
        public var toRefresh: Serie
    }

    public var refreshStatus: [PersistentIdentifier: Bool] = [:]
    
    private init() {}
    
    public func refreshCollection(collection: SerieCollection, onlyAllRead: Bool = true) async throws {
        guard refreshStatus[collection.id] == nil else { return }
        
        await updateRefreshStatus(id: collection.id, refreshing: true)

        let context = ModelContext(.dokusho())
        let data = try context.fetch(.seriesForSerieCollection(collectionId: collection.id))
        
        guard data.count != 0 else { return }
        
        Logger.libraryUpdater.debug("---------------------Fetching--------------------------")

        try await withThrowingTaskGroup(of: RefreshData.self) { group in
            for row in data {
                guard
                    let scraperId = row.scraperId,
                    let source = ScraperService.shared.getSource(sourceId: scraperId)
                else { throw "Source not found from scraper with id: \(String(describing: row.scraperId))" }

                _ = group.addTaskUnlessCancelled(priority: .background) {
                    return RefreshData(source: source, toRefresh: row)
                }
            }
 
            for try await data in group {
                await Task.yield()

                do {
                    guard
                        let internalId = data.toRefresh.internalId,
                        let sourceData = try? await data.source.fetchSerieDetail(serieId: internalId)
                    else { throw "Manga not found: \(String(describing: data.toRefresh.internalId))" }
                    
                    data.toRefresh.update(from: sourceData)
                } catch (let error) {
                    Logger.libraryUpdater.error("Error updating \(data.toRefresh.title): \(error)")
                    await updateRefreshStatus(id: collection.id, refreshing: false)
                }
            }
        }
        
        Logger.libraryUpdater.debug("---------------------Fetched--------------------------")
        
        await self.updateRefreshStatus(id: collection.id, refreshing: nil)
    }
    
    @MainActor
    public func updateRefreshStatus(id: PersistentIdentifier, refreshing: Bool? = nil) {
        self.refreshStatus[id] = refreshing
    }
}
