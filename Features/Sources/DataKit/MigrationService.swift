//
//  MigrationService.swift
//  Dokusho
//
//  Created by Migration Feature
//

import Foundation
import GRDB
import MangaScraper

// MARK: - Migration Types

public struct SourceMatch: Sendable {
    public let source: Source
    public let manga: SourceSmallManga

    public init(source: Source, manga: SourceSmallManga) {
        self.source = source
        self.manga = manga
    }
}

public struct MigrationResult: Sendable {
    public let newManga: Manga
    public let targetSource: Source
    public let chaptersMatched: Int
    public let chaptersMissed: Int
    public let readStatusTransferred: Int

    public init(newManga: Manga, targetSource: Source, chaptersMatched: Int, chaptersMissed: Int, readStatusTransferred: Int) {
        self.newManga = newManga
        self.targetSource = targetSource
        self.chaptersMatched = chaptersMatched
        self.chaptersMissed = chaptersMissed
        self.readStatusTransferred = readStatusTransferred
    }
}

public struct ChapterMappingPreview: Sendable {
    public let matched: [(source: MangaChapter, target: SourceChapter)]
    public let unmatchedSource: [MangaChapter]  // Read chapters that won't transfer
    public let unmatchedTarget: [SourceChapter] // New chapters on target

    public var matchedCount: Int { matched.count }
    public var unmatchedSourceCount: Int { unmatchedSource.count }
    public var unmatchedTargetCount: Int { unmatchedTarget.count }

    public init(matched: [(source: MangaChapter, target: SourceChapter)], unmatchedSource: [MangaChapter], unmatchedTarget: [SourceChapter]) {
        self.matched = matched
        self.unmatchedSource = unmatchedSource
        self.unmatchedTarget = unmatchedTarget
    }
}

// MARK: - Migration Service

public class MigrationService: @unchecked Sendable {
    public static let shared = MigrationService()
    private let database = AppDatabase.shared.database

    private init() {}

    // MARK: - Chapter Number Extraction

    /// Extracts chapter number from chapter title/name
    /// Handles formats like "Chapter 142", "Vol. 1 Chapter 10", "Ch. 5.5", etc.
    public func extractChapterNumber(from name: String) -> Double? {
        // Pattern to match chapter numbers, including decimals
        // Handles: "Chapter 142", "Ch. 5.5", "Vol. 1 Chapter 10 - Title", etc.
        let patterns = [
            "(?:chapter|ch\\.?)\\s*([0-9]+(?:\\.[0-9]+)?)",  // Chapter X or Ch. X
            "^([0-9]+(?:\\.[0-9]+)?)",  // Just a number at the start
            "#([0-9]+(?:\\.[0-9]+)?)"   // #X format
        ]

        let lowercased = name.lowercased()

        for pattern in patterns {
            if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive),
               let match = regex.firstMatch(in: lowercased, options: [], range: NSRange(lowercased.startIndex..., in: lowercased)),
               let range = Range(match.range(at: 1), in: lowercased) {
                let numberString = String(lowercased[range])
                return Double(numberString)
            }
        }

        return nil
    }

    // MARK: - Search & Match

    /// Search for potential matches on a specific source
    public func searchMatches(for manga: Manga, on targetSource: Source) async throws -> [SourceSmallManga] {
        let result = try await targetSource.fetchSearchManga(query: manga.title, page: 1)
        return result.mangas
    }

    /// Find first match across priority-ordered sources
    public func findFirstMatch(for manga: Manga, on targetSources: [Source]) async throws -> SourceMatch? {
        for source in targetSources {
            do {
                let results = try await searchMatches(for: manga, on: source)

                // Try to find an exact title match first
                if let exactMatch = results.first(where: {
                    $0.title.lowercased() == manga.title.lowercased()
                }) {
                    return SourceMatch(source: source, manga: exactMatch)
                }

                // Otherwise return the first result if available
                if let firstResult = results.first {
                    return SourceMatch(source: source, manga: firstResult)
                }
            } catch {
                // Continue to next source if this one fails
                print("Search failed on \(source.name): \(error)")
                continue
            }
        }

        return nil
    }

    // MARK: - Chapter Mapping

    /// Preview chapter mapping before migration
    public func previewChapterMapping(sourceChapters: [MangaChapter], targetChapters: [SourceChapter]) -> ChapterMappingPreview {
        var matched: [(MangaChapter, SourceChapter)] = []
        var unmatchedSource: [MangaChapter] = []

        for sourceChapter in sourceChapters {
            // Extract chapter number from source chapter
            guard let sourceNum = extractChapterNumber(from: sourceChapter.title) else {
                // If we can't extract a number and chapter was read, it's unmatched
                if sourceChapter.status == .read {
                    unmatchedSource.append(sourceChapter)
                }
                continue
            }

            // Find matching target chapter by number
            if let targetMatch = targetChapters.first(where: {
                guard let targetNum = extractChapterNumber(from: $0.name) else { return false }
                return abs(targetNum - sourceNum) < 0.001  // Allow small floating point differences
            }) {
                matched.append((sourceChapter, targetMatch))
            } else if sourceChapter.status == .read {
                unmatchedSource.append(sourceChapter)
            }
        }

        let matchedTargetIds = Set(matched.map { $0.1.id })
        let unmatchedTarget = targetChapters.filter { !matchedTargetIds.contains($0.id) }

        return ChapterMappingPreview(
            matched: matched,
            unmatchedSource: unmatchedSource,
            unmatchedTarget: unmatchedTarget
        )
    }

    // MARK: - Migration Execution

    /// Migrate a single manga to a new source
    public func migrateManga(
        from sourceManga: Manga,
        to targetSource: Source,
        targetMangaId: String,
        deleteOriginal: Bool = false
    ) async throws -> MigrationResult {
        // 1. Fetch full detail from target source
        let targetDetail = try await targetSource.fetchMangaDetail(id: targetMangaId)

        // 2. Get source chapters with read status
        let sourceChapters = try await database.read { db in
            try MangaChapter
                .filter(MangaChapter.Columns.mangaId == sourceManga.id)
                .fetchAll(db)
        }

        // 3. Preview chapter mapping
        let mapping = previewChapterMapping(sourceChapters: sourceChapters, targetChapters: targetDetail.chapters)

        // 4. Count read chapters that will be transferred
        let readStatusTransferred = mapping.matched.filter { $0.0.status == .read }.count

        // 5. Save new manga and chapters with transferred read status
        let newManga = try await database.write { db -> Manga in
            // Create new manga entry linked to target source
            var manga = Manga(from: targetDetail, sourceId: targetSource.id)
            manga.mangaCollectionId = sourceManga.mangaCollectionId

            // Check if manga already exists on target source
            if let existing = try Manga.fetchOne(db, mangaId: targetMangaId, scraperId: targetSource.id) {
                // Update existing manga's collection
                try Manga.updateCollection(id: existing.id, collectionId: sourceManga.mangaCollectionId, db)
                manga = existing
                manga.mangaCollectionId = sourceManga.mangaCollectionId
            } else {
                try manga.save(db)
            }

            // Get or create scraper record
            let scraper = try Scraper.fetchOne(db, source: targetSource)

            // Save chapters with transferred read status
            for (index, targetChap) in targetDetail.chapters.enumerated() {
                var chapter = MangaChapter(from: targetChap, position: index, mangaId: manga.id, scraperId: scraper.id)

                // Find matching source chapter to transfer read status
                if let matchedPair = mapping.matched.first(where: { $0.1.id == targetChap.id }) {
                    chapter.status = matchedPair.0.status
                    chapter.readAt = matchedPair.0.readAt
                }

                try chapter.save(db)
            }

            // Optionally delete original
            if deleteOriginal {
                // Delete chapters first (should cascade, but be explicit)
                try MangaChapter
                    .filter(MangaChapter.Columns.mangaId == sourceManga.id)
                    .deleteAll(db)
                try sourceManga.delete(db)
            }

            return manga
        }

        return MigrationResult(
            newManga: newManga,
            targetSource: targetSource,
            chaptersMatched: mapping.matchedCount,
            chaptersMissed: mapping.unmatchedSourceCount,
            readStatusTransferred: readStatusTransferred
        )
    }

    // MARK: - Data Queries

    /// Get all manga from a specific source that are in collections
    public func getMigratableManga(from sourceId: UUID) throws -> [Manga] {
        return try database.read { db in
            try Manga
                .all()
                .whereSource(sourceId)
                .isInCollection(true)
                .orderByTitle()
                .fetchAll(db)
        }
    }

    /// Get count of migratable manga for a source
    public func getMigratableMangaCount(from sourceId: UUID) throws -> Int {
        return try database.read { db in
            try Manga
                .all()
                .whereSource(sourceId)
                .isInCollection(true)
                .fetchCount(db)
        }
    }

    /// Get available target sources (excludes the source being migrated from)
    public func getAvailableTargets(excluding sourceId: UUID) -> [Source] {
        return MangaScraperService.shared.list.filter { $0.id != sourceId }
    }

    /// Get available target scrapers with their settings (isActive, position), ordered by position
    public func getAvailableTargetScrapers(excluding sourceId: UUID) throws -> [Scraper] {
        return try database.read { db in
            // Get all scrapers ordered by position
            let scrapers = try Scraper
                .all()
                .orderByPosition()
                .fetchAll(db)

            // Filter out the source we're migrating from and only include those that have a valid Source
            return scrapers.filter { scraper in
                scraper.id != sourceId && scraper.asSource() != nil
            }
        }
    }

    /// Get scrapers with manga count that have manga in collections
    public func getScrapersWithMigratableManga() throws -> [(scraper: Scraper, count: Int)] {
        return try database.read { db in
            let request = Scraper
                .select(Scraper.databaseSelection + [count(SQL(sql: "DISTINCT manga.rowid")).forKey("mangaCount")])
                .joining(required: Scraper.mangas.isInCollection())
                .group(Scraper.Columns.id)
                .orderByPosition()

            return try Row.fetchAll(db, request).compactMap { row -> (Scraper, Int)? in
                guard let scraper = try? Scraper(row: row),
                      let count = row["mangaCount"] as Int? else { return nil }
                return (scraper, count)
            }
        }
    }

    /// Fetch chapter preview for a target manga
    public func fetchTargetChapters(source: Source, mangaId: String) async throws -> [SourceChapter] {
        let detail = try await source.fetchMangaDetail(id: mangaId)
        return detail.chapters
    }

    /// Get chapters for a manga from database
    public func getSourceChapters(for manga: Manga) throws -> [MangaChapter] {
        return try database.read { db in
            try MangaChapter
                .filter(MangaChapter.Columns.mangaId == manga.id)
                .order(MangaChapter.Columns.position.asc)
                .fetchAll(db)
        }
    }

    /// Get read chapter count for a manga
    public func getReadChapterCount(for manga: Manga) throws -> Int {
        return try database.read { db in
            try MangaChapter
                .filter(MangaChapter.Columns.mangaId == manga.id)
                .filter(MangaChapter.Columns.status == ChapterStatus.read)
                .fetchCount(db)
        }
    }

    /// Get total chapter count for a manga
    public func getTotalChapterCount(for manga: Manga) throws -> Int {
        return try database.read { db in
            try MangaChapter
                .filter(MangaChapter.Columns.mangaId == manga.id)
                .fetchCount(db)
        }
    }

    /// Fetch full Manga by UUID
    public func getManga(by id: UUID) throws -> Manga? {
        return try database.read { db in
            try Manga.fetchOne(db, id: id)
        }
    }

    /// Fetch full Manga from PartialManga
    public func getFullManga(from partial: PartialManga) throws -> Manga? {
        return try getManga(by: partial.id)
    }
}
