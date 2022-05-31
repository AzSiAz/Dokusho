//
//  Mangasee.swift
//  Hanako
//
//  Created by Stephan Deumier on 30/12/2020.
//

import Foundation
import SwiftSoup
import SwiftyJSON

private struct MangaSeeDirectoryManga: Codable {
    let id: String
    let title: String
    let view: Int
    let lastUpdate: Date
    let alternateNames: [String]

    static func parseFromRawDirectory(raw: [MangaSeeDirectoryMangaRaw]) -> [MangaSeeDirectoryManga] {
        return raw.map { (value: MangaSeeDirectoryMangaRaw) -> MangaSeeDirectoryManga in
            MangaSeeDirectoryManga(id: value.i, title: value.s, view: Int(value.v)!, lastUpdate: Date(timeIntervalSince1970: TimeInterval(value.lt)), alternateNames: value.al)
        }
    }
}

private struct MangaSeeDirectoryMangaRaw: Codable {
    var i: String
    var s: String
    var v: String
    var al: [String]
    var lt: Int
}

private struct MangaSeeVMChapter: Codable {
    var chapter: Int
    var type: String
    var date: String
    var chapterName: String? = ""

    enum CodingKeys: String, CodingKey {
        case chapter = "Chapter"
        case type = "Type"
        case date = "Date"
        case chapterName = "ChapterName"
    }
}

private enum orderDirectory {
    case view, lastUpdate
}

private struct LDJSONInfoMainEntity: Codable {
    var alternateName: [String]
    var author: [String]
    var genre: [String]
}

private struct LDJSONInfo: Codable {
    var mainEntity: LDJSONInfoMainEntity
}

public class NepNepSource: MultiSource {
    static let MangaSee123Source = NepNepSource(baseUrl: "https://mangasee123.com", icon: "https://mangasee123.com/media/favicon.png", id: UUID(uuidString: "FFAECF22-DBB3-4B13-B4AF-665DC31CE775")!, name: "MangaSee")
    static let Manga4LifeSource = NepNepSource(baseUrl: "https://manga4life.com", icon: "https://manga4life.com/media/favicon.png", id: UUID(uuidString: "B6127CD7-A9C0-4610-8491-47DFCFD90DBC")!, name: "MangaLife")

    public var icon: String
    public var id: UUID
    public var name: String
    public var baseUrl: String
    public var lang = SourceLang.en
    public var supportsLatest = true
    public var headers = ["User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:71.0) Gecko/20100101 Firefox/77.0"]
    public var versionNumber: Float = 1.0
    public var nsfw: Bool = false
    public var updatedAt = Date.from(year: 2021, month: 12, day: 31)

    private var directory: [MangaSeeDirectoryManga] = []

    public required init(baseUrl: String, icon: String, id: UUID, name: String) {
        self.baseUrl = baseUrl
        self.icon = icon
        self.id = id
        self.name = name
    }

    public func fetchPopularManga(page: Int) async throws -> SourcePaginatedSmallManga {
        try await updateDirectory(page)
        return extractInfoFromDirectory(page: page, order: .view)
    }

    public func fetchLatestUpdates(page: Int) async throws -> SourcePaginatedSmallManga {
        try await updateDirectory(page)
        return extractInfoFromDirectory(page: page, order: .lastUpdate)
    }

    public func fetchSearchManga(query: String, page: Int) async throws -> SourcePaginatedSmallManga {
        try await updateDirectory(page)
        return searchMangaParse(query: query, page: page)
    }

    public func fetchMangaDetail(id: String) async throws -> SourceManga {
        let html = try await fetchHtml(url: "\(baseUrl)/manga/\(id)")

        let doc: Document = try SwiftSoup.parse(html)

        let interestingPart = "div.BoxBody > div.row"

        guard let title = try doc.select("\(interestingPart) h1").first()?.text().trimmingCharacters(in: .whitespacesAndNewlines) else {
            throw SourceError.parseError(error: "[NepNep] title not found")
        }
        guard let cover = try doc.select("\(interestingPart) img").first()?.attr("src") else {
            throw SourceError.parseError(error: "[NepNep] cover not found")
        }
        guard let synopsis = try doc.select("\(interestingPart) div.Content").first()?.text().trimmingCharacters(in: .whitespacesAndNewlines) else {
            throw SourceError.parseError(error: "[NepNep] synopsis not found")
        }
        guard let rawStatus = try doc.select("\(interestingPart) li.list-group-item:has(span:contains(Status)) a:contains(Scan)").first()?.text().trimmingCharacters(in: .whitespacesAndNewlines) else {
            throw SourceError.parseError(error: "[NepNep] status not found")
        }

        let rawType = try doc.select("\(interestingPart) li.list-group-item:has(span:contains(Type))").first()?.text().trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        let genres: [String] = try doc.select("\(interestingPart) li.list-group-item:has(span:contains(Genre)) a").array().map { try! $0.text().trimmingCharacters(in: .whitespacesAndNewlines) }
        let authors: [String] = try doc.select("\(interestingPart) li.list-group-item:has(span:contains(Author)) a").array().map { try! $0.text().trimmingCharacters(in: .whitespacesAndNewlines) }
        let chapters = try mangaChapterListParse(html, id)

        try await updateDirectory(1)
        let directoryManga = directory.first { $0.id == id }
        let alternateNames = directoryManga?.alternateNames ?? []

        return SourceManga(id: id, title: title, cover: cover, genres: genres, authors: authors, alternateNames: alternateNames, status: parseStatus(rawStatus), synopsis: synopsis, chapters: chapters, type: parseType(rawType))
    }

    public func fetchChapterImages(mangaId: String, chapterId: String) async throws -> [SourceChapterImage] {
        var html = try await fetchHtml(url: "\(baseUrl)/read-online/\(chapterId).html")
        
        if html.range(of: "MainFunction")?.upperBound == nil {
            html = try await fetchHtml(url: "\(baseUrl)/read-online/\(chapterId)")
        }

        guard let interrestingPartIndex = html.range(of: "MainFunction")?.upperBound else {
            throw SourceError.parseError(error: "[NepNep] MainFunction not found")
        }

        let interrestingPart = String(html[interrestingPartIndex...])

        guard let vmCurrChapterUpper = interrestingPart.range(of: "vm.CurChapter = ")?.upperBound else {
            throw SourceError.parseError(error: "[NepNep] vmCurrChapterUpper not found")
        }
        guard let vmCurrPathNameLower = interrestingPart.range(of: "vm.CurPathName")?.lowerBound else {
            throw SourceError.parseError(error: "[NepNep] vmCurrPathNameLower not found")
        }
        guard let vmCurrPathNameUpper = interrestingPart.range(of: "vm.CurPathName = ")?.upperBound else {
            throw SourceError.parseError(error: "[NepNep] vmCurrPathNameUpper not found")
        }
        guard let vmChapterLower = interrestingPart.range(of: "vm.CHAPTERS")?.lowerBound else {
            throw SourceError.parseError(error: "[NepNep] vmChapterLower not found")
        }

        guard let vmCurrChapterRaw = interrestingPart[vmCurrChapterUpper ... vmCurrPathNameLower]
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: ";", with: "")
            .dropLast()
            .data(using: .utf8) else { throw SourceError.parseError(error: "[NepNep] vmCurrChapterRaw not found") }

        let vmCurrPathName = interrestingPart[vmCurrPathNameUpper ... vmChapterLower]
            .dropFirst()
            .dropLast(4)
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: ";", with: "", options: .literal)
            .replacingOccurrences(of: "\"", with: "", options: .literal)

        let vmCurrChapterJSON = try JSON(data: vmCurrChapterRaw)

        let seasonURI = vmCurrChapterJSON.dictionaryValue["Directory"]!.stringValue.isEmpty ? "" : "\(vmCurrChapterJSON.dictionaryValue["Directory"]!.stringValue)/"
        let path = "\(vmCurrPathName)/manga/\(mangaId)/\(seasonURI)"
        let chNum = chapterImage(vmCurrChapterJSON.dictionaryValue["Chapter"]!.stringValue)

        // ideal: https://fan-official.lastation.us/manga/Magika-No-Kenshi-To-Shoukan-Maou/0076-001.png / https://fan-official.lastation.us/manga/Magika-No-Kenshi-To-Shoukan-Maou/0076-010.png
        let images = (1 ... vmCurrChapterJSON["Page"].intValue).map { number -> SourceChapterImage in
            let i = "000\(number)"
            let imageNum = i[i.index(i.endIndex, offsetBy: -3)...]
            
            return SourceChapterImage(index: number, imageUrl: "https://\(path)\(chNum)-\(imageNum).png")
        }

        return images
    }

    public func mangaUrl(mangaId: String) -> URL {
        return URL(string: "\(baseUrl)/manga/\(mangaId)")!
    }

    public func checkUpdates(mangaIds _: [String]) async throws {}

    private func searchMangaParse(query: String, page: Int) -> SourcePaginatedSmallManga {
        let chunks = directory.filter { mangaInDirectory -> Bool in
            mangaInDirectory.title.lowercased().contains(query.lowercased()) || mangaInDirectory.alternateNames.contains(where: { alternateName -> Bool in
                alternateName.lowercased().contains(query.lowercased())
            })
        }.chunked(into: 24)
        
        let mangas = chunks.count >= 1 ? chunks[page - 1].map { SourceSmallManga(id: $0.id, title: $0.title, thumbnailUrl: "https://cover.nep.li/cover/\($0.id).jpg") } : []
        
        return SourcePaginatedSmallManga(mangas: mangas, hasNextPage: page < chunks.count)
    }

    private func mangaChapterListParse(_ html: String, _ id: String) throws -> [SourceChapter] {
        guard let interrestingPartIndex = html.range(of: "MainFunction")?.upperBound else { return [] }
        let interrestingPart = String(html[interrestingPartIndex...])

        guard let vmDirectoryStartIndex = interrestingPart.range(of: "vm.Chapters = ")?.upperBound else { return [] }
        guard let vmDirectoryEndIndex = interrestingPart.range(of: "vm.NumSubs")?.lowerBound else { return [] }

        let vmDirectory = interrestingPart[vmDirectoryStartIndex ... vmDirectoryEndIndex]
        guard let lastBracket = vmDirectory.lastIndex(of: "]") else { return [] }

        let jsonData = vmDirectory[...lastBracket]
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: ";", with: "")

        let vmChapter = try! JSON(data: jsonData.data(using: .utf8)!)

        return try vmChapter.arrayValue.map { rawChapter -> SourceChapter in
            let chapter = rawChapter["Chapter"].stringValue
            let date = rawChapter["Date"].stringValue
            let type = rawChapter["Type"].stringValue
            let chapterName = rawChapter["ChapterName"].stringValue.isEmpty ? "\(type) \(chapterImage(chapter, clean: true))" : rawChapter["ChapterName"].stringValue
            let chapterId = "\(id)\(try chapterURLEncode(chapter))"

            return SourceChapter(name: chapterName, id: chapterId, dateUpload: convertToDate(date), externalUrl: nil)
        }
    }

    private func chapterImage(_ chapterIndex: String, clean: Bool = false) -> String {
        let t = String(chapterIndex.dropFirst().dropLast())

        let a = clean
            ? t.replacingOccurrences(of: "^0+", with: "", options: [.regularExpression])
            : t

        let b = Int(chapterIndex[chapterIndex.index(chapterIndex.endIndex, offsetBy: -1)...])
        
        if (b == 0 && !a.isEmpty) {
            return a
        }
        else if (b == 0 && a.isEmpty) {
            return "0"
        }
        else {
            return "\(a).\(b!)"
        }
    }

    private func chapterURLEncode(_ chapterIndex: String) throws -> String {
        guard let intChapterIndex = Int(chapterIndex) else { throw SourceError.parseError(error: "[NepNep] intChapterIndex not found") }
        var index = ""
        var suffix = ""

        let t = Int(chapterIndex[...chapterIndex.startIndex])
        if t != 1 { index = "-index-\(t!)"}

        let dgt = intChapterIndex < 100_000 ? 3 : intChapterIndex < 100_100 ? 4 : intChapterIndex < 101_000 ? 3 : intChapterIndex < 110_000 ? 2 : 1
        
        let startIndex = chapterIndex.index(chapterIndex.startIndex, offsetBy: dgt)
        let endIndex = chapterIndex.index(chapterIndex.endIndex, offsetBy: -2)
        let n = chapterIndex[startIndex...endIndex]

        let path = Int(chapterIndex[chapterIndex.index(before: chapterIndex.endIndex)...])
        if path != 0 {
            suffix = ".\(path!)"
        }

        return "-chapter-\(n)\(suffix)\(index)"
    }

    private func parseStatus(_ text: String) -> SourceMangaCompletion {
        switch text {
        case let t where t.lowercased().contains("ongoing"): return .ongoing
        case let t where t.lowercased().contains("complete"): return .complete
        default: return .unknown
        }
    }

    private func parseType(_ text: String) -> SourceMangaType {
        switch text {
        case let t where t.lowercased().contains("manga"): return .manga
        case let t where t.lowercased().contains("manhwa"): return .manhwa
        case let t where t.lowercased().contains("manhua"): return .manhua
        case let t where t.lowercased().contains("doujinshi"): return .doujinshi
        default: return .unknown
        }
    }

    private func extractDirectoryFromResponse(html: String) throws -> [MangaSeeDirectoryManga] {
        guard let interrestingPartIndex = html.range(of: "MainFunction")?.upperBound else {
            throw SourceError.parseError(error: "[NepNep] MainFunction not found")
        }
        let interrestingPart = String(html[interrestingPartIndex...])

        guard let vmDirectoryStartIndex = interrestingPart.range(of: "vm.Directory = ")?.upperBound else {
            throw SourceError.parseError(error: "[NepNep] vmDirectoryStartIndex not found")
        }
        guard let vmDirectoryEndIndex = interrestingPart.range(of: "vm.GetIntValue")?.lowerBound else {
            throw SourceError.parseError(error: "[NepNep] vmDirectoryEndIndex not found")
        }

        let vmDirectory = interrestingPart[vmDirectoryStartIndex ... vmDirectoryEndIndex]
        guard let lastBracket = vmDirectory.lastIndex(of: "]") else { throw SourceError.parseError(error: "[NepNep] lastBracket not found") }

        guard let jsonData = vmDirectory[...lastBracket]
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: ";", with: "")
            .data(using: .utf8) else { throw SourceError.parseError(error: "[NepNep] jsonData not found") }

        let rawData: [MangaSeeDirectoryMangaRaw] = try JSONDecoder().decode([MangaSeeDirectoryMangaRaw].self, from: jsonData)

        return MangaSeeDirectoryManga.parseFromRawDirectory(raw: rawData)
    }

    private func extractInfoFromDirectory(page: Int, order: orderDirectory) -> SourcePaginatedSmallManga {
        let chunks = directory.sorted { current, next -> Bool in
            if order == .lastUpdate {
                return current.lastUpdate > next.lastUpdate
            } else {
                return current.view > next.view
            }
        }.chunked(into: 24)

        return SourcePaginatedSmallManga(mangas: chunks[page - 1].map {
            SourceSmallManga(id: $0.id, title: $0.title, thumbnailUrl: "https://cover.nep.li/cover/\($0.id).jpg")
        }, hasNextPage: page < chunks.count)
    }

    private func updateDirectory(_ page: Int) async throws {
        if page != 1, !directory.isEmpty { return }

        let html = try await fetchHtml(url: "\(baseUrl)/search")
        directory = try extractDirectoryFromResponse(html: html)
    }

    private func fetchHtml(url: String) async throws -> String {
        guard let url = URL(string: url) else { throw "Not a url: \(url)" }

        var req = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData)
        headers.forEach { key, value in
            req.setValue(value, forHTTPHeaderField: key)
        }

        let (data, _) = try await URLSession.shared.data(for: req)
        guard !data.isEmpty else { throw SourceError.websiteError }

        return String(decoding: data, as: UTF8.self)
    }

    private func convertToDate(_ dateString: String) -> Date {
        let formatter = DateFormatter()

        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

        guard let date = formatter.date(from: dateString) else {
            return Date()
        }

        return date
    }
}
