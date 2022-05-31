// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let chapterList = try? newJSONDecoder().decode(ChapterList.self, from: jsonData)

import Foundation

// MARK: - ChapterList
struct MangaDexChapterListLatestRest: Codable {
    let result, response: String
    let data: [MangaDexChapterListLatestDatum]
    let limit, offset, total: Int
}

// MARK: - Datum
struct MangaDexChapterListLatestDatum: Codable {
    let id, type: String
    let attributes: MangaDexChapterListLatestAttributes
    let relationships: [MangaDexChapterListLatestRelationship]
}

// MARK: - Attributes
struct MangaDexChapterListLatestAttributes: Codable {
    let volume, chapter, title: String?
    let translatedLanguage: String
    let externalURL: String?
    let publishAt, readableAt, createdAt, updatedAt: String
    let pages, version: Int

    enum CodingKeys: String, CodingKey {
        case volume, chapter, title, translatedLanguage
        case externalURL = "externalUrl"
        case publishAt, readableAt, createdAt, updatedAt, pages, version
    }
}

// MARK: - Relationship
struct MangaDexChapterListLatestRelationship: Codable {
    let id, type: String
}
