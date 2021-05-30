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

class MangaSeeSource: Source {   
    var icon = "https://mangasee123.com/media/favicon.png";
    var id = "source.mangasee";
    var name = "Mangasee";
    var baseUrl = "https://mangasee123.com";
    var lang = LangSource.en;
    var supportsLatest = true;
    var headers = HTTPHeaders(["User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:71.0) Gecko/20100101 Firefox/77.0"])
    var versionNumber: Float = 1.0
    var updatedAt = Date.from(year: 2021, month: 01, day: 07)
    
    private var directory: [MangaSeeDirectoryManga] = []

    func fetchPopularManga(page: Int, completion: @escaping (Result<PaginatedSmallManga, SourceError>) -> Void) {
        return self.updateDirectory(page) { (updateResult) in
            switch(updateResult) {
            case .failure(let err): return completion(.failure(err))
            case .success(()): return completion(self.extractInfoFromDirectory(page: page, order: .view))
            }
        }
    }
    
    func fetchLatestUpdates(page: Int, completion: @escaping (Result<PaginatedSmallManga, SourceError>) -> Void) {
        return self.updateDirectory(page) { (updateResult) in
            switch(updateResult) {
            case .failure(let err): return completion(.failure(err))
            case .success(()): return completion(self.extractInfoFromDirectory(page: page, order: .lastUpdate))
            }
        }
    }
    
    func fetchSearchManga(query: String, page: Int, completion: @escaping (Result<PaginatedSmallManga, SourceError>) -> Void) {
        return self.updateDirectory(page) { (updateResult) in
            switch(updateResult) {
            case .failure(let err): return completion(.failure(err))
            case .success(()): return completion(.success(self.searchMangaParse(query: query, page: page)))
            }
        }
    }
    
    func fetchMangaDetail(id: String, completion: @escaping (Result<Manga, SourceError>) -> Void) {
        return mangaDetailRequest(mangaId: id) { requestResult in
            switch (requestResult) {
            case .failure(_): return completion(.failure(SourceError.fetchError))
            case .success(let html):
                do {
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
                    let genres: [String] = try doc.select("\(interestingPart) li.list-group-item:has(span:contains(Genre)) a").array().map { try! $0.text().trimmingCharacters(in: .whitespacesAndNewlines) }
                    let authors: [String] = try doc.select("\(interestingPart) li.list-group-item:has(span:contains(Author)) a").array().map { try! $0.text().trimmingCharacters(in: .whitespacesAndNewlines) }
                    let chapters = self.mangaChapterListParse(html, id)

                    return self.updateDirectory(1) { (res) in
                        let directoryManga = self.directory.first { $0.id == id }
                        let alternateNames = directoryManga?.alternateNames ?? []
                        
                        let manga = Manga(id: id, title: title, thumbnailUrl: thumbnailUrl, genres: genres, authors: authors, alternateNames: alternateNames, status: self.parseStatus(rawStatus), description: description, chapters: chapters)
                        
                        return completion(.success(manga))
                    }
                } catch let error {
                    debugPrint(error)
                    return completion(.failure(SourceError.parseError))
                }
            }
        }
    }
    
    func fetchChapterImages(mangaId: String, chapterId: String, completion: @escaping (Result<[ChapterImage], SourceError>) -> Void) {
        return self.mangaChapterImagesRequest(chapterId: chapterId) { requestResult in
            switch (requestResult) {
            case (.failure(_)): return completion(.failure(SourceError.fetchError))
            case (.success(let html)):
                guard let interrestingPartIndex = html.range(of: "MainFunction")?.upperBound else { return completion(.failure(SourceError.parseError))}
                
                let interrestingPart = String(html[interrestingPartIndex...])
                
                guard let vmCurrChapterUpper = interrestingPart.range(of: "vm.CurChapter = ")?.upperBound else { return completion(.failure(SourceError.parseError)) }
                guard let vmCurrPathNameLower = interrestingPart.range(of: "vm.CurPathName")?.lowerBound else { return completion(.failure(SourceError.parseError)) }
                guard let vmCurrPathNameUpper = interrestingPart.range(of: "vm.CurPathName = ")?.upperBound else { return completion(.failure(SourceError.parseError)) }
                guard let vmChapterLower = interrestingPart.range(of: "vm.CHAPTERS")?.lowerBound else { return completion(.failure(SourceError.parseError)) }

                let vmCurrChapterRaw = interrestingPart[vmCurrChapterUpper...vmCurrPathNameLower]
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                    .replacingOccurrences(of: ";", with: "")
                    .dropLast()
                    .data(using: .utf8)!
                
                let vmCurrPathName = interrestingPart[vmCurrPathNameUpper...vmChapterLower]
                    .dropFirst()
                    .dropLast(4)
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                    .replacingOccurrences(of: ";", with: "", options: .literal)
                    .replacingOccurrences(of: "\"", with: "", options: .literal)
                
                let vmCurrChapterJSON = try! JSON(data: vmCurrChapterRaw)
                
                let seasonURI = vmCurrChapterJSON.dictionaryValue["Directory"]!.stringValue.isEmpty ? "" : "\(vmCurrChapterJSON.dictionaryValue["Directory"]!.stringValue)/"
                let path = "\(vmCurrPathName)/manga/\(mangaId)/\(seasonURI)"
                let chNum = self.chapterImage(vmCurrChapterJSON.dictionaryValue["Chapter"]!.stringValue)
                
                // ideal: https://fan-official.lastation.us/manga/Magika-No-Kenshi-To-Shoukan-Maou/0076-001.png / https://fan-official.lastation.us/manga/Magika-No-Kenshi-To-Shoukan-Maou/0076-010.png
                let images = (1...vmCurrChapterJSON["Page"].intValue).map { (number) -> ChapterImage in
                    let i = "000\(number)"
                    return ChapterImage(index: number, imageUrl: "https://\(path)\(chNum)-0\(i[i.index(i.endIndex, offsetBy: -2)...]).png")
                }
                
                return completion(.success(images))
            }
        }
    }
    
    func mangaUrl(mangaId: String) -> URL {
        return URL(string: "\(self.baseUrl)/manga/\(mangaId)")!
    }
    
    private func searchMangaParse(query: String, page: Int) -> PaginatedSmallManga {
        let matchingMangasChunks = self.directory.filter { (mangaInDirectory) -> Bool in
            return mangaInDirectory.title.lowercased().contains(query.lowercased()) || mangaInDirectory.alternateNames.contains(where: { (alternateName) -> Bool in
                return alternateName.lowercased().contains(query.lowercased())
            })
        }.chunked(into: 24)

        return PaginatedSmallManga(mangas: matchingMangasChunks[page].map {
            return SmallManga(id: $0.id, title: $0.title, thumbnailUrl: "https://cover.nep.li/cover/\($0.id).jpg")
        }, hasNextPage: page != matchingMangasChunks.count)
    }
    
    private func mangaChapterImagesRequest(chapterId: String, _ completion: @escaping (Result<String, AFError>) -> Void) {
        return fetchHtml(url: "\(baseUrl)/read-online/\(chapterId).html", completionHandler: completion)
    }
    
    private func mangaChapterListParse(_ html: String, _ id: String) -> [Chapter] {
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
        
        return vmChapter.arrayValue.map { (rawChapter) -> Chapter in
            let chapter = rawChapter["Chapter"].stringValue
            let date = rawChapter["Date"].stringValue
            let type = rawChapter["Type"].stringValue
            let chapterName = rawChapter["ChapterName"].stringValue.isEmpty ? "\(type) \(chapterImage(chapter, clean: true))" : rawChapter["ChapterName"].stringValue
            
            return Chapter(name: chapterName, id: "\(id)\(chapterURLEncode(chapter))", dateUpload: convertToDate(date))
        }
    }
    
    private func chapterImage(_ chapterIndex: String, clean: Bool = false) -> String {
        let t = String(chapterIndex.dropFirst().dropLast())
        
        let a = clean
            ? t.replacingOccurrences(of: "^([0-9])", with: "", options: [.regularExpression])
            : t

        let b = Int(chapterIndex[chapterIndex.index(chapterIndex.endIndex, offsetBy: -1)...])
        
        return b == 0 ? a : "\(a).\(b!)"
    }
    
    private func chapterURLEncode(_ chapterIndex: String) -> String {
        var index = ""
        var suffix = ""
        
        let t = Int(chapterIndex[...chapterIndex.startIndex])
        if t != 1 {
            index = "-index-\(t!)"
        }
        
        let n = chapterIndex[chapterIndex.index(after: chapterIndex.startIndex)...chapterIndex.index(chapterIndex.endIndex, offsetBy: -2)]
        let path = Int(chapterIndex[chapterIndex.index(chapterIndex.endIndex, offsetBy: -1)...])
        if path != 0 {
            suffix = ".\(path!)"
        }
        
        return "-chapter-\(n)\(suffix)\(index)"
    }
    
    private func parseStatus(_ text: String) -> MangaCompletion {
        switch text {
        case let t where t.lowercased().contains("ongoing"): return .ongoing
        case let t where t.lowercased().contains("complete"): return .complete
        default: return .unknown
        }
        
    }
    
    private func mangaDetailRequest(mangaId: String, _ completion: @escaping (Result<String, AFError>) -> Void) {
        return fetchHtml(url: "\(self.baseUrl)/manga/\(mangaId)", completionHandler: completion)
    }
        
    private func extractDirectoryFromResponse(html: String) -> Result<[MangaSeeDirectoryManga], SourceError> {
        guard let interrestingPartIndex = html.range(of: "MainFunction")?.upperBound else { return .failure(.parseError) }
        let interrestingPart = String(html[interrestingPartIndex...])

        guard let vmDirectoryStartIndex = interrestingPart.range(of: "vm.Directory = ")?.upperBound else { return .failure(.parseError) }
        guard let vmDirectoryEndIndex = interrestingPart.range(of: "vm.GetIntValue")?.lowerBound else { return .failure(.parseError) }
        
        let vmDirectory = interrestingPart[vmDirectoryStartIndex...vmDirectoryEndIndex]
        guard let lastBracket = vmDirectory.lastIndex(of: "]") else { return .failure(.parseError) }
        
        let jsonData = vmDirectory[...lastBracket]
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: ";", with: "")
            .data(using: .utf8)!

        let rawData: [MangaSeeDirectoryMangaRaw] = try! JSONDecoder().decode([MangaSeeDirectoryMangaRaw].self, from: jsonData)
                
        return .success(MangaSeeDirectoryManga.parseFromRawDirectory(raw: rawData))
    }
    
    private func extractInfoFromDirectory(page: Int, order: orderDirectory) -> Result<PaginatedSmallManga, SourceError> {
        let chunks = self.directory.sorted { (current, next) -> Bool in
            if (order == .lastUpdate) {
                return current.lastUpdate > next.lastUpdate
            }
            else {
                return current.view > next.view
            }
        }.chunked(into: 24)

        return .success(PaginatedSmallManga(mangas: chunks[page-1].map {
            return SmallManga(id: $0.id, title: $0.title, thumbnailUrl: "https://cover.nep.li/cover/\($0.id).jpg")
        }, hasNextPage: page != chunks.count))
    }
    
    private func updateDirectory(_ page: Int, completion: @escaping (Result<Void, SourceError>) -> Void) {
        if (page != 1 && !self.directory.isEmpty) {
            return completion(.success(()))
        }
        
        self.fetchHtml(url: "\(self.baseUrl)/search") { (result) in
            switch(result) {
            case .failure(_): return completion(.failure(.websiteError))
            case .success(let html):
                switch self.extractDirectoryFromResponse(html: html) {
                case .success(let mangas):
                    self.directory = mangas
                    return completion(.success(()))
                case .failure(let err): return completion(.failure(err))
                }
            }
        }
    }
    
    private func fetchHtml(url: String, completionHandler: @escaping (Result<String, AFError>) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            AF.request(url, headers: self.headers).validate().responseString { (data) in
                DispatchQueue.main.async {
                    switch (data.result) {
                    case .success(let html): return completionHandler(.success(html))
                    case .failure(let error): return completionHandler(.failure(error))
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
