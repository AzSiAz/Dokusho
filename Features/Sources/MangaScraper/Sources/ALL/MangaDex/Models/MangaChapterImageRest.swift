// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let mangaDexChapterImagesRESTWelcome = try? newJSONDecoder().decode(MangaDexChapterImagesRESTWelcome.self, from: jsonData)

import Foundation

// MARK: - MangaDexChapterImagesRESTWelcome
struct MangaDexChapterImagesREST: Codable {
    let result: String?
    let baseURL: String?
    let chapter: MangaDexChapterImagesRESTChapter?

    enum CodingKeys: String, CodingKey {
        case result = "result"
        case baseURL = "baseUrl"
        case chapter = "chapter"
    }
}

// MARK: - MangaDexChapterImagesRESTChapter
struct MangaDexChapterImagesRESTChapter: Codable {
    let hash: String?
    let data: [String]?
    let dataSaver: [String]?

    enum CodingKeys: String, CodingKey {
        case hash = "hash"
        case data = "data"
        case dataSaver = "dataSaver"
    }
}
