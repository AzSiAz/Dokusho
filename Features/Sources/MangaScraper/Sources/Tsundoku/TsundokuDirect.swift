//
//  TsundokuDirect.swift
//  Dokusho
//
//  Created by Claude on 30/01/2026.
//

import Foundation

public struct TsundokuDirect: Source, @unchecked Sendable {
    public static let shared = TsundokuDirect()

    private let config = TsundokuConfiguration.shared
    private let apiVersion = "v1"

    public var name: String {
        config.displayName.isEmpty ? "Tsundoku" : config.displayName
    }

    public var id: UUID {
        config.generateSourceId(suffix: "/direct")
    }

    public var versionNumber: Float = 1.0
    public var updatedAt: Date = Date.from(year: 2026, month: 01, day: 30)
    public var lang: SourceLang = .en
    public var icon: String { "\(config.apiUrl)/favicon.png" }
    public var baseUrl: String { config.apiUrl }
    public var supportsLatest: Bool = true
    public var nsfw: Bool = false

    public var headers: [String: String] {
        var h = [String: String]()
        if !config.apiKey.isEmpty {
            h["X-API-Key"] = config.apiKey
        }
        h["User-Agent"] = "DokushoiOS/1.0"
        h["Accept"] = "application/json"
        return h
    }

    // MARK: - Source Protocol Implementation

    public func fetchPopularManga(page: Int) async throws -> SourcePaginatedSmallManga {
        let url = "\(config.apiUrl)/api/\(apiVersion)/serie?page=\(page)&pageSize=24&language=En"
        let response: TsundokuSerieListResponse = try await fetchJSON(url: url)

        let mangas = response.data.map { serie in
            SourceSmallManga(
                id: serie.id,
                title: serie.title,
                thumbnailUrl: serie.cover ?? ""
            )
        }

        let hasNextPage = response.pagination.page < response.pagination.totalPages
        return SourcePaginatedSmallManga(mangas: mangas, hasNextPage: hasNextPage)
    }

    public func fetchLatestUpdates(page: Int) async throws -> SourcePaginatedSmallManga {
        // Use main serie endpoint sorted by updated_at (default behavior)
        let url = "\(config.apiUrl)/api/\(apiVersion)/serie?page=\(page)&pageSize=24&language=En"
        let response: TsundokuSerieListResponse = try await fetchJSON(url: url)

        let mangas = response.data.map { serie in
            SourceSmallManga(
                id: serie.id,
                title: serie.title,
                thumbnailUrl: serie.cover ?? ""
            )
        }

        let hasNextPage = response.pagination.page < response.pagination.totalPages
        return SourcePaginatedSmallManga(mangas: mangas, hasNextPage: hasNextPage)
    }

    public func fetchSearchManga(query: String, page: Int) async throws -> SourcePaginatedSmallManga {
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
        let url = "\(config.apiUrl)/api/\(apiVersion)/serie?q=\(encodedQuery)&page=\(page)&pageSize=24&language=En"
        let response: TsundokuSerieListResponse = try await fetchJSON(url: url)

        let mangas = response.data.map { serie in
            SourceSmallManga(
                id: serie.id,
                title: serie.title,
                thumbnailUrl: serie.cover ?? ""
            )
        }

        let hasNextPage = response.pagination.page < response.pagination.totalPages
        return SourcePaginatedSmallManga(mangas: mangas, hasNextPage: hasNextPage)
    }

    public func fetchMangaDetail(id: String) async throws -> SourceManga {
        let detailUrl = "\(config.apiUrl)/api/\(apiVersion)/serie/\(id)"
        let chaptersUrl = "\(config.apiUrl)/api/\(apiVersion)/serie/\(id)/chapters?lang=En"

        async let serieTask: TsundokuSerie = fetchJSON(url: detailUrl)
        async let chaptersTask: TsundokuChaptersResponse = fetchJSON(url: chaptersUrl)

        let serie = try await serieTask
        let chaptersResponse = try await chaptersTask

        let status = parseStatus(serie.status?.first)
        let type = parseType(serie.type)

        let chapters = chaptersResponse.chapters
            .filter { ($0.enabled ?? true) && ($0.language?.lowercased() == "en" || $0.language == "En") }
            .map { chapter -> SourceChapter in
                let chapterName = formatChapterName(chapter)

                return SourceChapter(
                    name: chapterName,
                    id: chapter.id,
                    dateUpload: chapter.dateUpload ?? Date.now,
                    externalUrl: nil  // Always fetch from Tsundoku API, not external source
                )
            }

        return SourceManga(
            id: serie.id,
            title: serie.title,
            cover: serie.cover ?? "",
            genres: serie.genres?.map { $0.title } ?? [],
            authors: serie.authors?.map { $0.name } ?? [],
            alternateNames: [],
            status: status,
            synopsis: serie.synopsis ?? "No synopsis available",
            chapters: chapters,
            type: type
        )
    }

    public func fetchChapterImages(mangaId: String, chapterId: String) async throws -> [SourceChapterImage] {
        let url = "\(config.apiUrl)/api/\(apiVersion)/serie/\(mangaId)/chapters/\(chapterId)/data"
        let response: TsundokuChapterDataResponse = try await fetchJSON(url: url)

        guard response.hasData else {
            throw SourceError.parseError(error: "Chapter has no data available")
        }

        return response.pages
            .filter { !($0.permanentlyFailed ?? false) }
            .compactMap { page -> SourceChapterImage? in
                guard let imageUrl = page.url else { return nil }
                return SourceChapterImage(index: page.index, imageUrl: imageUrl)
            }
            .sorted { $0.index < $1.index }
    }

    public func mangaUrl(mangaId: String) -> URL {
        URL(string: "\(config.apiUrl)/serie/\(mangaId)")!
    }

    public func checkUpdates(mangaIds: [String]) async throws {
        throw SourceError.notImplemented
    }

    // MARK: - Helper Methods

    private func fetchJSON<T: Decodable>(url: String) async throws -> T {
        guard let requestUrl = URL(string: url) else {
            throw SourceError.parseError(error: "Invalid URL: \(url)")
        }

        var request = URLRequest(url: requestUrl, cachePolicy: .reloadIgnoringLocalCacheData)
        headers.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw SourceError.fetchError
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw SourceError.websiteError
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(T.self, from: data)
    }

    private func parseStatus(_ status: String?) -> SourceMangaCompletion {
        switch status?.lowercased() {
        case "ongoing": return .ongoing
        case "completed", "complete": return .complete
        default: return .unknown
        }
    }

    private func parseType(_ type: String?) -> SourceMangaType {
        switch type?.lowercased() {
        case "manga": return .manga
        case "manhwa": return .manhwa
        case "manhua": return .manhua
        case "doujinshi": return .doujinshi
        default: return .unknown
        }
    }

    private func formatChapterName(_ chapter: TsundokuChapter) -> String {
        var parts = [String]()

        if let volume = chapter.volumeNumber, volume > 0 {
            parts.append("Vol. \(Int(volume))")
        } else if let volumeName = chapter.volumeName, !volumeName.isEmpty {
            parts.append(volumeName)
        }

        if let chapterNum = chapter.chapterNumber {
            if chapterNum == floor(chapterNum) {
                parts.append("Ch. \(Int(chapterNum))")
            } else {
                parts.append("Ch. \(chapterNum)")
            }
        }

        if let title = chapter.title, !title.isEmpty {
            parts.append("- \(title)")
        }

        return parts.isEmpty ? "Chapter" : parts.joined(separator: " ")
    }

}
