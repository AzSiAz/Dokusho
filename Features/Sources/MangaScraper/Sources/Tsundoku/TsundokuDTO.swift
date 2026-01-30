//
//  TsundokuDTO.swift
//  Dokusho
//
//  Created by Claude on 30/01/2026.
//

import Foundation

// MARK: - Pagination

public struct TsundokuPagination: Codable, Sendable {
    public let page: Int
    public let pageSize: Int
    public let total: Int
    public let totalPages: Int
}

// MARK: - Serie List Response

public struct TsundokuSerieListResponse: Codable, Sendable {
    public let data: [TsundokuSerie]
    public let pagination: TsundokuPagination
}

// MARK: - Recent Series Response (different format - no pagination)

public struct TsundokuRecentResponse: Codable, Sendable {
    public let series: [TsundokuRecentSerie]
}

public struct TsundokuRecentSerie: Codable, Sendable {
    public let id: String
    public let title: String
    public let cover: String?
    public let sources: [String]?
    public let chapterCount: Int?
    public let importedAt: String?
}

// MARK: - Serie

public struct TsundokuSerie: Codable, Sendable {
    public let id: String
    public let title: String
    public let synopsis: String?
    public let cover: String?
    public let type: String?
    public let status: [String]?
    public let updatedAt: String?
    public let genres: [TsundokuGenre]?
    public let authors: [TsundokuPerson]?
    public let artists: [TsundokuPerson]?

    enum CodingKeys: String, CodingKey {
        case id, title, synopsis, cover, type, status, genres, authors, artists
        case updatedAt = "updated_at"
    }
}

public struct TsundokuGenre: Codable, Sendable {
    public let id: String
    public let title: String
}

public struct TsundokuPerson: Codable, Sendable {
    public let id: String
    public let name: String
}

// MARK: - Chapters

public struct TsundokuChaptersResponse: Codable, Sendable {
    public let chapters: [TsundokuChapter]
}

public struct TsundokuChapter: Codable, Sendable {
    public let id: String
    public let title: String?
    public let chapterNumber: Double?
    public let volumeNumber: Double?
    public let volumeName: String?
    public let language: String?
    public let dateUpload: Date?
    public let enabled: Bool?
    public let externalUrl: String?
    public let source: TsundokuChapterSource?

    enum CodingKeys: String, CodingKey {
        case id, title, language, enabled, source
        case chapterNumber = "chapter_number"
        case volumeNumber = "volume_number"
        case volumeName = "volume_name"
        case dateUpload = "date_upload"
        case externalUrl = "external_url"
    }
}

public struct TsundokuChapterSource: Codable, Sendable {
    public let id: String
    public let externalId: String?
    public let name: String?

    enum CodingKeys: String, CodingKey {
        case id, name
        case externalId = "external_id"
    }
}

// MARK: - Chapter Data

public struct TsundokuChapterDataResponse: Codable, Sendable {
    public let pages: [TsundokuPage]
    public let hasData: Bool
}

public struct TsundokuPage: Codable, Sendable {
    public let index: Int
    public let type: String?
    public let url: String?
    public let permanentlyFailed: Bool?

    enum CodingKeys: String, CodingKey {
        case index, type, url
        case permanentlyFailed = "permanently_failed"
    }
}

// MARK: - Sources (for WeebCentral)

public struct TsundokuSourcesResponse: Codable, Sendable {
    public let sources: [TsundokuSource]?

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let sources = try? container.decode([TsundokuSource].self) {
            self.sources = sources
        } else {
            self.sources = nil
        }
    }
}

public struct TsundokuSource: Codable, Sendable {
    public let id: String
    public let externalId: String?
    public let name: String
    public let icon: String?

    enum CodingKeys: String, CodingKey {
        case id, name, icon
        case externalId = "external_id"
    }
}

// MARK: - Source Search Response

public struct TsundokuSourceSearchResponse: Codable, Sendable {
    public let series: [TsundokuSourceSearchResult]
    public let hasNextPage: Bool
    public let page: Int
}

public struct TsundokuSourceSearchResult: Codable, Sendable {
    public let id: String
    public let title: String
    public let cover: String?
    public let imported: Bool?
    public let serieId: String?
}

// MARK: - Source Detail Response

public struct TsundokuSourceDetailResponse: Codable, Sendable {
    public let id: String
    public let title: String
    public let alternateTitles: [String]?
    public let cover: String?
    public let synopsis: String?
    public let status: [String]?
    public let type: String?
    public let genres: [String]?
    public let authors: [String]?
    public let artists: [String]?
}

// MARK: - Connection Test Response

public struct TsundokuConnectionTestResponse: Codable, Sendable {
    public let data: [TsundokuSerie]?
    public let pagination: TsundokuPagination?
}
