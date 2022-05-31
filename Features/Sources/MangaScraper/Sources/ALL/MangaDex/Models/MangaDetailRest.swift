// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let mangaDexMangaDetailREST = try? newJSONDecoder().decode(MangaDexMangaDetailREST.self, from: jsonData)

import Foundation

// MARK: - MangaDexMangaDetailREST
struct MangaDexMangaDetailREST: Codable {
    let result: String?
    let response: String?
    let data: MangaDexMangaDetailData?
}

// MARK: - MangaDexMangaDetailData
struct MangaDexMangaDetailData: Codable {
    let id: String?
    let type: String?
    let attributes: MangaDexMangaDetailDataAttributes?
    let relationships: [MangaDexMangaDetailRelationship]?
}

// MARK: - MangaDexMangaDetailDataAttributes
struct MangaDexMangaDetailDataAttributes: Codable {
    let title: MangaDexMangaDetailTitle?
    let altTitles: [MangaDexMangaDetailAltTitle]?
    let description: MangaDexMangaDetailDescription?
    let isLocked: Bool?
    let links: MangaDexMangaDetailLinks?
    let originalLanguage: String?
    let lastVolume: String?
    let lastChapter: String?
    let publicationDemographic: String?
    let status: String?
    let year: Int?
    let contentRating: String?
    let tags: [MangaDexMangaDetailTag]?
    let state: String?
    let createdAt: String?
    let updatedAt: String?
    let version: Int?
}

// MARK: - MangaDexMangaDetailAltTitle
struct MangaDexMangaDetailAltTitle: Codable {
    let ko: String?
    let en: String?
    let ru: String?
}

// MARK: - MangaDexMangaDetailDescription
struct MangaDexMangaDetailDescription: Codable {
    let en: String?
    let ko: String?
}

// MARK: - MangaDexMangaDetailLinks
struct MangaDexMangaDetailLinks: Codable {
    let al: String?
    let kt: String?
    let mu: String?
    let nu: String?
    let raw: String?
}

// MARK: - MangaDexMangaDetailTag
struct MangaDexMangaDetailTag: Codable {
    let id: String?
    let type: String?
    let attributes: MangaDexMangaDetailTagAttributes?
}

// MARK: - MangaDexMangaDetailTagAttributes
struct MangaDexMangaDetailTagAttributes: Codable {
    let name: MangaDexMangaDetailTitle?
    let group: String?
    let version: Int?
}

// MARK: - MangaDexMangaDetailTitle
struct MangaDexMangaDetailTitle: Codable {
    let en: String?
}

// MARK: - MangaDexMangaDetailRelationship
struct MangaDexMangaDetailRelationship: Codable {
    let id: String?
    let type: String?
    let attributes: MangaDexMangaDetailRelationshipAttributes?
}

// MARK: - MangaDexMangaDetailRelationshipAttributes
struct MangaDexMangaDetailRelationshipAttributes: Codable {
    let name: String?
    let imageURL: String?
    let twitter: String?
    let pixiv: String?
    let melonBook: String?
    let fanBox: String?
    let booth: String?
    let nicoVideo: String?
    let skeb: String?
    let fantia: String?
    let tumblr: String?
    let youtube: String?
    let website: String?
    let createdAt: String?
    let updatedAt: String?
    let version: Int?
    let attributesDescription: String?
    let volume: String?
    let fileName: String?
}
