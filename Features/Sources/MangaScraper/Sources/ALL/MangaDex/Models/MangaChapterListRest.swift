// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let mangaDexChapterListREST = try? newJSONDecoder().decode(MangaDexChapterListREST.self, from: jsonData)

import Foundation

// MARK: - MangaDexChapterListREST
struct MangaDexChapterListREST: Codable {
    let result: String?
    let response: String?
    let data: [MangaDexChapterListDatum]?
    let limit: Int?
    let offset: Int?
    let total: Int?
}

// MARK: - MangaDexChapterListDatum
struct MangaDexChapterListDatum: Codable {
    let id: String?
    let type: String?
    let attributes: MangaDexChapterListDatumAttributes?
    let relationships: [MangaDexChapterListRelationship]?
}

// MARK: - MangaDexChapterListDatumAttributes
struct MangaDexChapterListDatumAttributes: Codable {
    let volume: String?
    let chapter: String?
    let title: String?
    let translatedLanguage: String?
    let hash: String?
    let data: [String]?
    let dataSaver: [String]?
    let externalUrl: String?
    let publishAt: String?
    let createdAt: String?
    let updatedAt: String?
    let version: Int?
}

// MARK: - MangaDexChapterListRelationship
struct MangaDexChapterListRelationship: Codable {
    let id: String?
    let type: String?
    let attributes: MangaDexChapterListRelationshipAttributes?
}

// MARK: - MangaDexChapterListRelationshipAttributes
struct MangaDexChapterListRelationshipAttributes: Codable {
    let name: String?
    let altNames: [MangaDexChapterListAltName]?
    let locked: Bool?
    let website: String?
    let ircServer: String?
    let ircChannel: String?
    let discord: String?
    let contactEmail: String?
    let attributesDescription: String?
    let twitter: String?
    let focusedLanguages: [String]?
    let official: Bool?
    let verified: Bool?
    let publishDelay: String?
    let createdAt: String?
    let updatedAt: String?
    let inactive: Bool?
    let version: Int?
    let username: String?
    let roles: [String]?
}

// MARK: - MangaDexChapterListAltName
struct MangaDexChapterListAltName: Codable {
    let en: String?
}
