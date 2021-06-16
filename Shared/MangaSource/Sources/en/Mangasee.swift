//
//  Mangasee.swift
//  Hanako
//
//  Created by Stephan Deumier on 30/12/2020.
//

import Foundation
import Alamofire
import SwiftSoup
import SwiftyJSON

private struct MangaSeeDirectoryManga: Codable {
    let id: String
    let title: String
    let view: Int
    let lastUpdate: Date
    let alternateNames: [String]
    
    static func parseFromRawDirectory(raw: [MangaSeeDirectoryMangaRaw]) -> [MangaSeeDirectoryManga] {
        return raw.map{ (value: MangaSeeDirectoryMangaRaw) -> MangaSeeDirectoryManga in
            return MangaSeeDirectoryManga(id: value.i, title: value.s, view: Int(value.v)!, lastUpdate: Date(timeIntervalSince1970: TimeInterval(value.lt)) , alternateNames: value.al)
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

public class MangaSeeSource: Source {
    public var icon = "https://mangasee123.com/media/favicon.png";
    public var id = 1;
    public var name = "Mangasee";
    public var baseUrl = "https://mangasee123.com";
    public var lang = SourceLang.en;
    public var supportsLatest = true;
    public var headers = HTTPHeaders(["User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:71.0) Gecko/20100101 Firefox/77.0"])
    public var versionNumber: Float = 1.0
    public var updatedAt = Date.from(year: 2021, month: 01, day: 07)
    
    private var directory: [MangaSeeDirectoryManga] = []
    
    public init() {}

    public func fetchPopularManga(page: Int) async throws -> SourcePaginatedSmallManga {
        try await self.updateDirectory(page)
        return self.extractInfoFromDirectory(page: page, order: .view)
    }
    
    public func fetchLatestUpdates(page: Int) async throws -> SourcePaginatedSmallManga {
        try await self.updateDirectory(page)
        return self.extractInfoFromDirectory(page: page, order: .lastUpdate)
    }
    
    public func fetchSearchManga(query: String, page: Int) async throws -> SourcePaginatedSmallManga {
        try await self.updateDirectory(page)
        return self.searchMangaParse(query: query, page: page)
    }
    
    public func fetchMangaDetail(id: String) async throws -> SourceManga {
        let html = try await fetchHtml(url: "\(self.baseUrl)/manga/\(id)")

        let doc: Document = try SwiftSoup.parse(html)
        
        let interestingPart = "div.BoxBody > div.row"

        guard let title = try doc.select("\(interestingPart) h1").first()?.text().trimmingCharacters(in: .whitespacesAndNewlines) else {
            throw SourceError.parseError
        }
        guard let thumbnailUrl = try doc.select("\(interestingPart) img").first()?.attr("src") else {
            throw SourceError.parseError
        }
        guard let description = try doc.select("\(interestingPart) div.Content").first()?.text().trimmingCharacters(in: .whitespacesAndNewlines) else {
            throw SourceError.parseError
        }
        guard let rawStatus = try doc.select("\(interestingPart) li.list-group-item:has(span:contains(Status)) a:contains(Scan)").first()?.text().trimmingCharacters(in: .whitespacesAndNewlines) else {
            throw SourceError.parseError
        }
        
        let rawType = try doc.select("\(interestingPart) li.list-group-item:has(span:contains(Type))").first()?.text().trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        
        let genres: [String] = try doc.select("\(interestingPart) li.list-group-item:has(span:contains(Genre)) a").array().map { try! $0.text().trimmingCharacters(in: .whitespacesAndNewlines) }
        let authors: [String] = try doc.select("\(interestingPart) li.list-group-item:has(span:contains(Author)) a").array().map { try! $0.text().trimmingCharacters(in: .whitespacesAndNewlines) }
        let chapters = try self.mangaChapterListParse(html, id)

        try await self.updateDirectory(1)
        let directoryManga = self.directory.first { $0.id == id }
        let alternateNames = directoryManga?.alternateNames ?? []
        
        return SourceManga(id: id, title: title, thumbnailUrl: thumbnailUrl, genres: genres, authors: authors, alternateNames: alternateNames, status: self.parseStatus(rawStatus), description: description, chapters: chapters, type: parseType(rawType))
    }
    
    public func fetchChapterImages(mangaId: String, chapterId: String) async throws -> [SourceChapterImage] {
        let html = try await fetchHtml(url: "\(baseUrl)/read-online/\(chapterId).html")

        guard let interrestingPartIndex = html.range(of: "MainFunction")?.upperBound else {
            throw SourceError.parseError
        }
        
        let interrestingPart = String(html[interrestingPartIndex...])
        
        guard let vmCurrChapterUpper = interrestingPart.range(of: "vm.CurChapter = ")?.upperBound else {
            throw SourceError.parseError
        }
        guard let vmCurrPathNameLower = interrestingPart.range(of: "vm.CurPathName")?.lowerBound else {
            throw SourceError.parseError
        }
        guard let vmCurrPathNameUpper = interrestingPart.range(of: "vm.CurPathName = ")?.upperBound else {
            throw SourceError.parseError
        }
        guard let vmChapterLower = interrestingPart.range(of: "vm.CHAPTERS")?.lowerBound else {
            throw SourceError.parseError
        }

        guard let vmCurrChapterRaw = interrestingPart[vmCurrChapterUpper...vmCurrPathNameLower]
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .replacingOccurrences(of: ";", with: "")
                .dropLast()
                .data(using: .utf8) else { throw SourceError.parseError }
        
        let vmCurrPathName = interrestingPart[vmCurrPathNameUpper...vmChapterLower]
            .dropFirst()
            .dropLast(4)
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: ";", with: "", options: .literal)
            .replacingOccurrences(of: "\"", with: "", options: .literal)
        
        let vmCurrChapterJSON = try JSON(data: vmCurrChapterRaw)
        
        let seasonURI = vmCurrChapterJSON.dictionaryValue["Directory"]!.stringValue.isEmpty ? "" : "\(vmCurrChapterJSON.dictionaryValue["Directory"]!.stringValue)/"
        let path = "\(vmCurrPathName)/manga/\(mangaId)/\(seasonURI)"
        let chNum = self.chapterImage(vmCurrChapterJSON.dictionaryValue["Chapter"]!.stringValue)
        
        // ideal: https://fan-official.lastation.us/manga/Magika-No-Kenshi-To-Shoukan-Maou/0076-001.png / https://fan-official.lastation.us/manga/Magika-No-Kenshi-To-Shoukan-Maou/0076-010.png
        let images = (1...vmCurrChapterJSON["Page"].intValue).map { (number) -> SourceChapterImage in
            let i = "000\(number)"
            return SourceChapterImage(index: number, imageUrl: "https://\(path)\(chNum)-0\(i[i.index(i.endIndex, offsetBy: -2)...]).png")
        }
        
        return images
    }
    
    public func mangaUrl(mangaId: String) -> URL {
        return URL(string: "\(self.baseUrl)/manga/\(mangaId)")!
    }
    
    public func checkUpdates(mangaIds: [String]) async throws -> Void {}
    
    private func searchMangaParse(query: String, page: Int) -> SourcePaginatedSmallManga {
        let matchingMangasChunks = self.directory.filter { (mangaInDirectory) -> Bool in
            return mangaInDirectory.title.lowercased().contains(query.lowercased()) || mangaInDirectory.alternateNames.contains(where: { (alternateName) -> Bool in
                return alternateName.lowercased().contains(query.lowercased())
            })
        }.chunked(into: 24)

        return SourcePaginatedSmallManga(mangas: matchingMangasChunks[page].map {
            return SourceSmallManga(id: $0.id, title: $0.title, thumbnailUrl: "https://cover.nep.li/cover/\($0.id).jpg")
        }, hasNextPage: page != matchingMangasChunks.count)
    }
    
    private func mangaChapterListParse(_ html: String, _ id: String) throws -> [SourceChapter] {
        guard let interrestingPartIndex = html.range(of: "MainFunction")?.upperBound else { return [] }
        let interrestingPart = String(html[interrestingPartIndex...])

        guard let vmDirectoryStartIndex = interrestingPart.range(of: "vm.Chapters = ")?.upperBound else { return [] }
        guard let vmDirectoryEndIndex = interrestingPart.range(of: "vm.NumSubs")?.lowerBound else { return [] }
        
        let vmDirectory = interrestingPart[vmDirectoryStartIndex...vmDirectoryEndIndex]
        guard let lastBracket = vmDirectory.lastIndex(of: "]") else { return [] }

        let jsonData = vmDirectory[...lastBracket]
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: ";", with: "")
                
        let vmChapter = try! JSON(data: jsonData.data(using: .utf8)!)
        
        return try vmChapter.arrayValue.map { (rawChapter) -> SourceChapter in
            let chapter = rawChapter["Chapter"].stringValue
            let date = rawChapter["Date"].stringValue
            let type = rawChapter["Type"].stringValue
            let chapterName = rawChapter["ChapterName"].stringValue.isEmpty ? "\(type) \(chapterImage(chapter, clean: true))" : rawChapter["ChapterName"].stringValue
            let chapterId = "\(id)\(try chapterURLEncode(chapter))"
            
            return SourceChapter(name: chapterName, id: chapterId, dateUpload: convertToDate(date))
        }
    }
    
    private func chapterImage(_ chapterIndex: String, clean: Bool = false) -> String {
        let t = String(chapterIndex.dropFirst().dropLast())
        
        let a = clean
            ? t.replacingOccurrences(of: "^0+", with: "", options: [.regularExpression])
            : t

        let b = Int(chapterIndex[chapterIndex.index(chapterIndex.endIndex, offsetBy: -1)...])

        return b == 0 ? a : "\(a).\(b!)"
    }
    
    private func chapterURLEncode(_ chapterIndex: String) throws -> String {
        guard let intChapterIndex = Int(chapterIndex) else { throw SourceError.parseError }
        var index = ""
        var suffix = ""
        
        let t = Int(chapterIndex[...chapterIndex.startIndex])
        if t != 1 {
            index = "-index-\(t!)"
        }
        
        let dgt = intChapterIndex < 100100 ? 4 : intChapterIndex < 101000 ? 3 : intChapterIndex < 110000 ? 2 : 1

        let n = chapterIndex[chapterIndex.index(chapterIndex.startIndex, offsetBy: dgt)...chapterIndex.index(chapterIndex.endIndex, offsetBy: -2)]

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
            throw SourceError.parseError
        }
        let interrestingPart = String(html[interrestingPartIndex...])

        guard let vmDirectoryStartIndex = interrestingPart.range(of: "vm.Directory = ")?.upperBound else {
            throw SourceError.parseError
        }
        guard let vmDirectoryEndIndex = interrestingPart.range(of: "vm.GetIntValue")?.lowerBound else {
            throw SourceError.parseError
        }
        
        let vmDirectory = interrestingPart[vmDirectoryStartIndex...vmDirectoryEndIndex]
        guard let lastBracket = vmDirectory.lastIndex(of: "]") else { throw SourceError.parseError }
        
        guard let jsonData = vmDirectory[...lastBracket]
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .replacingOccurrences(of: ";", with: "")
                .data(using: .utf8) else { throw SourceError.parseError }

        let rawData: [MangaSeeDirectoryMangaRaw] = try JSONDecoder().decode([MangaSeeDirectoryMangaRaw].self, from: jsonData)
                
        return MangaSeeDirectoryManga.parseFromRawDirectory(raw: rawData)
    }
    
    private func extractInfoFromDirectory(page: Int, order: orderDirectory) -> SourcePaginatedSmallManga {
        let chunks = self.directory.sorted { (current, next) -> Bool in
            if (order == .lastUpdate) {
                return current.lastUpdate > next.lastUpdate
            }
            else {
                return current.view > next.view
            }
        }.chunked(into: 24)

        return SourcePaginatedSmallManga(mangas: chunks[page-1].map {
            return SourceSmallManga(id: $0.id, title: $0.title, thumbnailUrl: "https://cover.nep.li/cover/\($0.id).jpg")
        }, hasNextPage: page != chunks.count)
    }
    
    private func updateDirectory(_ page: Int) async throws -> Void {
        if (page != 1 && !self.directory.isEmpty) { return }
        
        let html = try await self.fetchHtml(url: "\(self.baseUrl)/search")
        self.directory = try self.extractDirectoryFromResponse(html: html)
    }
    
    private func fetchHtml(url: String) async throws -> String {
        return try await withCheckedThrowingContinuation { c in
            DispatchQueue.global(qos: .userInitiated).async {
                AF.request(url, method: .get ,headers: self.headers).validate().responseString { (data) in
                    DispatchQueue.main.async {
                        switch data.result {
                            case .failure: c.resume(throwing: SourceError.fetchError)
                            case .success(let html): c.resume(returning: html)
                        }
                    }
                }
            }
        }
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
