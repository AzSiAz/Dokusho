// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let mangaDexMangaList = try? newJSONDecoder().decode(MangaDexMangaList.self, from: jsonData)

import Foundation

// MARK: - MangaDexMangaList
struct MangaDexMangaListRest: Codable {
    let result, response: String
    let data: [MangaDexMangaListDatum]
    let limit, offset, total: Int
}

// MARK: - MangaDexMangaListDatum
struct MangaDexMangaListDatum: Codable {
    let id, type: String
    let attributes: MangaDexMangaListDatumAttributes
    let relationships: [MangaDexMangaListRelationship]
}

// MARK: - MangaDexMangaListDatumAttributes
struct MangaDexMangaListDatumAttributes: Codable {
    let title: MangaDexMangaListTitle
    let altTitles: [MangaDexMangaListAltTitle]

    enum CodingKeys: String, CodingKey {
        case title, altTitles
    }
}

// MARK: - MangaDexMangaListAltTitle
struct MangaDexMangaListAltTitle: Codable {
    let zh, zhRo, en, id: String?
    let vi, ru, ko, es: String?
    let ja, th, zhHk, pt: String?
    let ar, jaRo, ms, esLa: String?
    let de, ptBr, pl, fr: String?
    let tr, fa, it, tl: String?

    enum CodingKeys: String, CodingKey {
        case zh
        case zhRo = "zh-ro"
        case en, id, vi, ru, ko, es, ja, th
        case zhHk = "zh-hk"
        case pt, ar
        case jaRo = "ja-ro"
        case ms
        case esLa = "es-la"
        case de
        case ptBr = "pt-br"
        case pl, fr, tr, fa, it, tl
    }
}

// MARK: - MangaDexMangaListTitle
struct MangaDexMangaListTitle: Codable {
    let en, zh: String?
}

// MARK: - MangaDexMangaListRelationship
struct MangaDexMangaListRelationship: Codable {
    let id, type: String
    let attributes: MangaDexMangaListRelationshipAttributes?
    let related: String?
}

// MARK: - MangaDexMangaListRelationshipAttributes
struct MangaDexMangaListRelationshipAttributes: Codable {
    let attributesDescription: String
    let volume: String?
    let fileName, locale, createdAt, updatedAt: String
    let version: Int

    enum CodingKeys: String, CodingKey {
        case attributesDescription = "description"
        case volume, fileName, locale, createdAt, updatedAt, version
    }
}
