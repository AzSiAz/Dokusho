//
//  MassMigrationVM.swift
//  Dokusho
//
//  Created by Migration Feature
//

import Foundation
import SwiftUI
import MangaScraper
import DataKit

@MainActor
public class MassMigrationVM: ObservableObject {
    private let migrationService = MigrationService.shared

    @Published public var sourceScrapers: [(scraper: Scraper, count: Int)] = []
    @Published public var selectedSourceId: UUID?
    @Published public var targetSources: [TargetSourceConfig] = []
    @Published public var migratableItems: [MigrationItem] = []
    @Published public var isLoading: Bool = false
    @Published public var isSearching: Bool = false
    @Published public var isMigrating: Bool = false
    @Published public var progress: MigrationProgress?
    @Published public var error: String?
    @Published public var deleteOriginals: Bool = false

    public struct TargetSourceConfig: Identifiable {
        public let id: UUID
        public let source: Source
        public var isEnabled: Bool
        public var priority: Int

        public init(source: Source, isEnabled: Bool = true, priority: Int) {
            self.id = source.id
            self.source = source
            self.isEnabled = isEnabled
            self.priority = priority
        }
    }

    public struct MigrationItem: Identifiable {
        public let id: UUID
        public let manga: Manga
        public var matchStatus: MatchStatus
        public var matchedSource: Source?
        public var matchedManga: SourceSmallManga?
        public var matchConfidence: MatchConfidence
        public var isSelected: Bool

        public init(manga: Manga) {
            self.id = manga.id
            self.manga = manga
            self.matchStatus = .pending
            self.matchedSource = nil
            self.matchedManga = nil
            self.matchConfidence = .none
            self.isSelected = false
        }
    }

    public enum MatchConfidence: Equatable {
        case none
        case exact      // Titles match exactly (case-insensitive)
        case similar    // One title contains the other
        case fuzzy      // First search result, titles differ

        public var displayText: String {
            switch self {
            case .none: return ""
            case .exact: return "Exact match"
            case .similar: return "Similar title"
            case .fuzzy: return "Best guess"
            }
        }

        public var icon: String {
            switch self {
            case .none: return ""
            case .exact: return "checkmark.seal.fill"
            case .similar: return "checkmark.circle"
            case .fuzzy: return "questionmark.circle"
            }
        }

        public var color: String {
            switch self {
            case .none: return "secondary"
            case .exact: return "green"
            case .similar: return "orange"
            case .fuzzy: return "yellow"
            }
        }
    }

    public enum MatchStatus: Equatable {
        case pending
        case searching
        case matched
        case notFound

        public var displayText: String {
            switch self {
            case .pending: return "Pending"
            case .searching: return "Searching..."
            case .matched: return "Matched"
            case .notFound: return "Not Found"
            }
        }
    }

    public struct MigrationProgress {
        public var total: Int
        public var completed: Int
        public var failed: Int
        public var currentTitle: String?

        public var percentComplete: Double {
            guard total > 0 else { return 0 }
            return Double(completed + failed) / Double(total) * 100
        }
    }

    public init() {}

    // MARK: - Load Data

    public func loadSourceScrapers() {
        isLoading = true
        defer { isLoading = false }

        do {
            sourceScrapers = try migrationService.getScrapersWithMigratableManga()
        } catch {
            self.error = "Failed to load sources: \(error.localizedDescription)"
        }
    }

    public func selectSource(_ scraperId: UUID) async {
        selectedSourceId = scraperId
        await loadMigratableMangas()
        loadTargetSources()
    }

    private func loadMigratableMangas() async {
        guard let sourceId = selectedSourceId else { return }

        isLoading = true
        defer { isLoading = false }

        do {
            let mangas = try migrationService.getMigratableManga(from: sourceId)
            migratableItems = mangas.map { MigrationItem(manga: $0) }
        } catch {
            self.error = "Failed to load manga: \(error.localizedDescription)"
        }
    }

    private func loadTargetSources() {
        guard let sourceId = selectedSourceId else { return }

        do {
            let scrapers = try migrationService.getAvailableTargetScrapers(excluding: sourceId)
            targetSources = scrapers.enumerated().compactMap { index, scraper in
                guard let source = scraper.asSource() else { return nil }
                return TargetSourceConfig(
                    source: source,
                    isEnabled: scraper.isActive,  // Use scraper's active status as default
                    priority: index  // Already ordered by position from the query
                )
            }
        } catch {
            print("Failed to load target sources: \(error)")
            // Fallback to old behavior
            let available = migrationService.getAvailableTargets(excluding: sourceId)
            targetSources = available.enumerated().map { index, source in
                TargetSourceConfig(source: source, isEnabled: true, priority: index)
            }
        }
    }

    // MARK: - Auto-Match

    public func autoMatchAll() async {
        guard !isSearching else { return }

        isSearching = true
        error = nil

        let enabledSources = targetSources
            .filter { $0.isEnabled }
            .sorted { $0.priority < $1.priority }
            .map { $0.source }

        guard !enabledSources.isEmpty else {
            error = "No target sources enabled"
            isSearching = false
            return
        }

        // Mark all as searching
        for i in migratableItems.indices {
            migratableItems[i].matchStatus = .searching
        }

        // Search for each manga
        for i in migratableItems.indices {
            let manga = migratableItems[i].manga

            do {
                if let match = try await migrationService.findFirstMatch(for: manga, on: enabledSources) {
                    migratableItems[i].matchStatus = .matched
                    migratableItems[i].matchedSource = match.source
                    migratableItems[i].matchedManga = match.manga
                    migratableItems[i].matchConfidence = calculateConfidence(
                        sourceTitle: manga.title,
                        targetTitle: match.manga.title
                    )
                    migratableItems[i].isSelected = true
                } else {
                    migratableItems[i].matchStatus = .notFound
                    migratableItems[i].matchConfidence = .none
                    migratableItems[i].isSelected = false
                }
            } catch {
                migratableItems[i].matchStatus = .notFound
                migratableItems[i].matchConfidence = .none
                migratableItems[i].isSelected = false
            }
        }

        isSearching = false
    }

    private func calculateConfidence(sourceTitle: String, targetTitle: String) -> MatchConfidence {
        let source = sourceTitle.lowercased().trimmingCharacters(in: .whitespaces)
        let target = targetTitle.lowercased().trimmingCharacters(in: .whitespaces)

        if source == target {
            return .exact
        } else if source.contains(target) || target.contains(source) {
            return .similar
        } else {
            return .fuzzy
        }
    }

    public func manualSearch(item: MigrationItem, on source: Source, query: String) async -> [SourceSmallManga] {
        do {
            let searchManga = Manga(
                mangaId: item.manga.mangaId,
                title: query.isEmpty ? item.manga.title : query,
                cover: item.manga.cover,
                synopsis: ""
            )
            return try await migrationService.searchMatches(for: searchManga, on: source)
        } catch {
            return []
        }
    }

    public func selectMatch(for itemId: UUID, manga: SourceSmallManga, source: Source) {
        if let index = migratableItems.firstIndex(where: { $0.id == itemId }) {
            migratableItems[index].matchStatus = .matched
            migratableItems[index].matchedSource = source
            migratableItems[index].matchedManga = manga
            migratableItems[index].matchConfidence = calculateConfidence(
                sourceTitle: migratableItems[index].manga.title,
                targetTitle: manga.title
            )
            migratableItems[index].isSelected = true
        }
    }

    // MARK: - Selection

    public func toggleSelection(for itemId: UUID) {
        if let index = migratableItems.firstIndex(where: { $0.id == itemId }) {
            migratableItems[index].isSelected.toggle()
        }
    }

    public func selectAll() {
        for i in migratableItems.indices {
            if migratableItems[i].matchStatus == .matched {
                migratableItems[i].isSelected = true
            }
        }
    }

    public func deselectAll() {
        for i in migratableItems.indices {
            migratableItems[i].isSelected = false
        }
    }

    public var selectedCount: Int {
        migratableItems.filter { $0.isSelected && $0.matchStatus == .matched }.count
    }

    public var matchedCount: Int {
        migratableItems.filter { $0.matchStatus == .matched }.count
    }

    public var totalCount: Int {
        migratableItems.count
    }

    // MARK: - Source Configuration

    public func moveTargetSource(from source: IndexSet, to destination: Int) {
        targetSources.move(fromOffsets: source, toOffset: destination)
        for (index, _) in targetSources.enumerated() {
            targetSources[index].priority = index
        }
    }

    public func toggleTargetSource(_ sourceId: UUID) {
        if let index = targetSources.firstIndex(where: { $0.id == sourceId }) {
            targetSources[index].isEnabled.toggle()
        }
    }

    public var enabledSourceCount: Int {
        targetSources.filter { $0.isEnabled }.count
    }

    // MARK: - Migration Execution

    public func executeSelectedMigrations() async {
        let selectedItems = migratableItems.filter {
            $0.isSelected && $0.matchStatus == .matched && $0.matchedManga != nil && $0.matchedSource != nil
        }

        guard !selectedItems.isEmpty else {
            error = "No items selected for migration"
            return
        }

        isMigrating = true
        progress = MigrationProgress(total: selectedItems.count, completed: 0, failed: 0, currentTitle: nil)

        for item in selectedItems {
            guard let targetManga = item.matchedManga, let targetSource = item.matchedSource else {
                progress?.failed += 1
                continue
            }

            progress?.currentTitle = item.manga.title

            do {
                _ = try await migrationService.migrateManga(
                    from: item.manga,
                    to: targetSource,
                    targetMangaId: targetManga.id,
                    deleteOriginal: deleteOriginals
                )
                progress?.completed += 1

                // Remove from list if successful
                if let index = migratableItems.firstIndex(where: { $0.id == item.id }) {
                    migratableItems.remove(at: index)
                }
            } catch {
                progress?.failed += 1
                print("Migration failed for \(item.manga.title): \(error)")
            }
        }

        isMigrating = false
    }

    public var canMigrate: Bool {
        selectedCount > 0 && !isMigrating && !isSearching
    }
}
