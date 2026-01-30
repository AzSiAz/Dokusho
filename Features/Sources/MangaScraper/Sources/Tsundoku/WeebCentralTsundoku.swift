//
//  WeebCentralTsundoku.swift
//  Dokusho
//
//  Created by Claude on 30/01/2026.
//

import Foundation

public struct WeebCentralTsundoku: Source, @unchecked Sendable {
    public static let shared = WeebCentralTsundoku()

    private let config = TsundokuConfiguration.shared
    private let apiVersion = "v1"
    private let sourceExternalId = "weebcentral"

    public var name: String = "WeebCentral"

    public var id: UUID {
        config.generateSourceId(suffix: "/weebcentral")
    }

    public var versionNumber: Float = 1.0
    public var updatedAt: Date = Date.from(year: 2026, month: 01, day: 30)
    public var lang: SourceLang = .en
    public var icon: String = "https://weebcentral.com/favicon.ico"
    public var baseUrl: String { config.apiUrl }
    public var supportsLatest: Bool = false
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

    // Cached source ID from the backend
    private var cachedSourceId: String?

    // MARK: - Source Protocol Implementation

    public func fetchPopularManga(page: Int) async throws -> SourcePaginatedSmallManga {
        // WeebCentral is search-only, return empty results
        return SourcePaginatedSmallManga(mangas: [], hasNextPage: false)
    }

    public func fetchLatestUpdates(page: Int) async throws -> SourcePaginatedSmallManga {
        // WeebCentral is search-only, return empty results
        return SourcePaginatedSmallManga(mangas: [], hasNextPage: false)
    }

    public func fetchSearchManga(query: String, page: Int) async throws -> SourcePaginatedSmallManga {
        let sourceId = try await getSourceId()
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
        let url = "\(config.apiUrl)/api/\(apiVersion)/sources/\(sourceId)/search?q=\(encodedQuery)&page=\(page)"

        let response: TsundokuSourceSearchResponse = try await fetchJSON(url: url)

        let mangas = response.series.map { result in
            SourceSmallManga(
                id: result.id,
                title: result.title,
                thumbnailUrl: result.cover ?? ""
            )
        }

        return SourcePaginatedSmallManga(mangas: mangas, hasNextPage: response.hasNextPage)
    }

    public func fetchMangaDetail(id: String) async throws -> SourceManga {
        let sourceId = try await getSourceId()
        let encodedId = id.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? id
        let url = "\(config.apiUrl)/api/\(apiVersion)/sources/\(sourceId)/detail?serieId=\(encodedId)"

        let detail: TsundokuSourceDetailResponse = try await fetchJSON(url: url)

        let status = parseStatus(detail.status?.first)
        let type = parseType(detail.type)

        return SourceManga(
            id: detail.id,
            title: detail.title,
            cover: detail.cover ?? "",
            genres: detail.genres ?? [],
            authors: detail.authors ?? [],
            alternateNames: detail.alternateTitles ?? [],
            status: status,
            synopsis: detail.synopsis ?? "No synopsis available",
            chapters: [],
            type: type
        )
    }

    public func fetchChapterImages(mangaId: String, chapterId: String) async throws -> [SourceChapterImage] {
        throw SourceError.notImplemented
    }

    public func mangaUrl(mangaId: String) -> URL {
        URL(string: "https://weebcentral.com/series/\(mangaId)")!
    }

    public func checkUpdates(mangaIds: [String]) async throws {
        throw SourceError.notImplemented
    }

    // MARK: - Helper Methods

    private func getSourceId() async throws -> String {
        let url = "\(config.apiUrl)/api/\(apiVersion)/sources"

        let sources: [TsundokuSource] = try await fetchJSON(url: url)

        guard let weebCentral = sources.first(where: { $0.externalId == sourceExternalId || $0.name.lowercased() == "weebcentral" }) else {
            throw SourceError.parseError(error: "WeebCentral source not found on this Tsundoku server")
        }

        return weebCentral.id
    }

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
}
