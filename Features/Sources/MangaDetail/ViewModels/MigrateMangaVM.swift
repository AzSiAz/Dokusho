//
//  MigrateMangaVM.swift
//  Dokusho
//
//  Created by Migration Feature
//

import Foundation
import SwiftUI
import MangaScraper
import DataKit

@MainActor
public class MigrateMangaVM: ObservableObject {
    private let migrationService = MigrationService.shared

    public let manga: Manga
    public let currentScraper: Scraper

    @Published public var targetSources: [TargetSourceConfig] = []
    @Published public var matchResult: SourceMatch?
    @Published public var selectedMatch: SourceSmallManga?
    @Published public var selectedSource: Source?
    @Published public var chapterPreview: ChapterMappingPreview?
    @Published public var isSearching: Bool = false
    @Published public var isMigrating: Bool = false
    @Published public var deleteOriginal: Bool = false
    @Published public var error: String?
    @Published public var migrationComplete: Bool = false
    @Published public var migrationResult: MigrationResult?

    // For manual search
    @Published public var searchResults: [SourceSmallManga] = []
    @Published public var searchQuery: String = ""

    // Chapter counts
    @Published public var readChapterCount: Int = 0
    @Published public var totalChapterCount: Int = 0

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

    public init(manga: Manga, scraper: Scraper) {
        self.manga = manga
        self.currentScraper = scraper
        self.searchQuery = manga.title
    }

    // MARK: - Load Data

    public func loadTargetSources() {
        do {
            let scrapers = try migrationService.getAvailableTargetScrapers(excluding: currentScraper.id)
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
            let available = migrationService.getAvailableTargets(excluding: currentScraper.id)
            targetSources = available.enumerated().map { index, source in
                TargetSourceConfig(source: source, isEnabled: true, priority: index)
            }
        }
    }

    public func loadChapterCounts() {
        do {
            readChapterCount = try migrationService.getReadChapterCount(for: manga)
            totalChapterCount = try migrationService.getTotalChapterCount(for: manga)
        } catch {
            print("Failed to load chapter counts: \(error)")
        }
    }

    // MARK: - Search

    public func searchForMatch() async {
        guard !isSearching else { return }

        isSearching = true
        error = nil
        matchResult = nil
        chapterPreview = nil
        searchResults = []

        defer { isSearching = false }

        let enabledSources = targetSources
            .filter { $0.isEnabled }
            .sorted { $0.priority < $1.priority }
            .map { $0.source }

        guard !enabledSources.isEmpty else {
            error = "No target sources enabled"
            return
        }

        do {
            if let match = try await migrationService.findFirstMatch(for: manga, on: enabledSources) {
                matchResult = match
                selectedMatch = match.manga
                selectedSource = match.source
                await loadChapterPreview()
            } else {
                error = "No match found on any enabled source"
            }
        } catch {
            self.error = "Search failed: \(error.localizedDescription)"
        }
    }

    public func manualSearch(on source: Source) async {
        guard !isSearching else { return }

        isSearching = true
        error = nil
        searchResults = []

        defer { isSearching = false }

        do {
            let query = searchQuery.isEmpty ? manga.title : searchQuery
            searchResults = try await migrationService.searchMatches(for: Manga(
                mangaId: manga.mangaId,
                title: query,
                cover: manga.cover,
                synopsis: manga.synopsis
            ), on: source)
        } catch {
            self.error = "Search failed: \(error.localizedDescription)"
        }
    }

    public func selectMatch(_ match: SourceSmallManga, from source: Source) async {
        selectedMatch = match
        selectedSource = source
        matchResult = SourceMatch(source: source, manga: match)
        await loadChapterPreview()
    }

    // MARK: - Chapter Preview

    public func loadChapterPreview() async {
        guard let match = selectedMatch, let source = selectedSource else { return }

        do {
            let sourceChapters = try migrationService.getSourceChapters(for: manga)
            let targetChapters = try await migrationService.fetchTargetChapters(source: source, mangaId: match.id)

            chapterPreview = migrationService.previewChapterMapping(
                sourceChapters: sourceChapters,
                targetChapters: targetChapters
            )
        } catch {
            self.error = "Failed to load chapter preview: \(error.localizedDescription)"
        }
    }

    // MARK: - Migration

    public func executeMigration() async throws -> MigrationResult {
        guard let match = selectedMatch, let source = selectedSource else {
            throw MigrationError.noMatchSelected
        }

        isMigrating = true
        error = nil

        defer { isMigrating = false }

        do {
            let result = try await migrationService.migrateManga(
                from: manga,
                to: source,
                targetMangaId: match.id,
                deleteOriginal: deleteOriginal
            )

            migrationResult = result
            migrationComplete = true
            return result
        } catch {
            self.error = "Migration failed: \(error.localizedDescription)"
            throw error
        }
    }

    // MARK: - Source Configuration

    public func moveTargetSource(from source: IndexSet, to destination: Int) {
        targetSources.move(fromOffsets: source, toOffset: destination)
        // Update priorities
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

    public var hasMatch: Bool {
        selectedMatch != nil && selectedSource != nil
    }

    public var canMigrate: Bool {
        hasMatch && !isMigrating
    }
}

// MARK: - Errors

public enum MigrationError: LocalizedError {
    case noMatchSelected
    case migrationFailed(String)

    public var errorDescription: String? {
        switch self {
        case .noMatchSelected:
            return "No target manga selected for migration"
        case .migrationFailed(let reason):
            return "Migration failed: \(reason)"
        }
    }
}
