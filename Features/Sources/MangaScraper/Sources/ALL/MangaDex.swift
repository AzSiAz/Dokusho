//
//  File.swift
//  
//
//  Created by Stef on 02/01/2022.
//

import Foundation
import JAYSON
import Collections

public struct MangaDex: Source, @unchecked Sendable {
    public static let shared = MangaDex.init()
    
    public var name: String = "MangaDex"
    public var id: UUID = UUID(uuidString: "3599756d-8fa0-4ca2-aafc-096c3d776ae1")!
    public var versionNumber: Float = 1.0
    public var updatedAt: Date = Date.from(year: 2022, month: 01, day: 02)
    public var lang: SourceLang = .all
    public var icon: String = "https://mangadex.org/favicon.ico"
    public var baseUrl: String = "https://api.mangadex.org"
    public var supportsLatest: Bool = true
    public var headers = [String : String]()
    public var nsfw: Bool = true
    
    public func fetchPopularManga(page: Int) async throws -> SourcePaginatedSmallManga {
        return try await getMangaList(page: page, query: "order[followedCount]=desc")
    }
    
    public func fetchLatestUpdates(page: Int) async throws -> SourcePaginatedSmallManga {
        return try await getLatestManga(page: page)
    }
    
    public func fetchSearchManga(query: String, page: Int) async throws -> SourcePaginatedSmallManga {
        return try await getMangaList(page: page, query: "title=\(query.replacingOccurrences(of: " ", with: "%20"))")
    }
    
    public func fetchMangaDetail(id: String) async throws -> SourceManga {
        do {
            let html = try await fetchHtml(url: "\(baseUrl)/manga/\(id)?&includes[]=author&includes[]=artist&includes[]=cover_art")
            guard let json = try? JSON(jsonString: html).next("data") else { throw SourceError.parseError(error: "[MangaDex] Error getting json data for `fetchMangaDetail`") }

            let title = getMangaTitle(data: json)
            let cover = getCover(mangaId: id, data: json)
            let synopsis = (try? json.next("attributes").next("description").next("en").getString()) ?? "No synopsis found"
            let genres = try json.next("attributes").next("tags").getArray().compactMap { try? $0.next("attributes").next("name").next("en").getString() }
            let authors = try json.next("relationships").getArray().filter { (try? $0.next("type").getString()) == "author" }.compactMap { try? $0.next("attributes").next("name").getString() }
            let altTitle = try json.next("attributes").next("altTitles").getArray().compactMap { try? $0.next("en").getString() }
            
            print(synopsis)
            
            var status: SourceMangaCompletion {
                let status = try? json.next("attributes").next("status").getString()
                switch status {
                case "completed": return SourceMangaCompletion.complete
                case "ongoing": return SourceMangaCompletion.ongoing
                default: return SourceMangaCompletion.unknown
                }
            }
            
            var type: SourceMangaType {
                let found = try? json.next("attributes").next("originalLanguage").getString()
                switch found {
                case "ko": return SourceMangaType.manhwa
                case "jp": return SourceMangaType.manga
                case "zh": return SourceMangaType.manhua
                default: return SourceMangaType.unknown
                }
            }
            
            return SourceManga(
                id: id,
                title: title,
                cover: cover,
                genres: genres,
                authors: authors,
                alternateNames: altTitle,
                status: status,
                synopsis: synopsis,
                chapters: try await fetchChapters(mangaId: id),
                type: type
            )
        } catch(let error) {
            debugPrint(error)
            throw error
        }
    }
    
    public func fetchChapterImages(mangaId: String, chapterId: String) async throws -> [SourceChapterImage] {
        do {
            let html = try await fetchHtml(url: "https://api.mangadex.org/at-home/server/\(chapterId)?forcePort443=false")
            guard let json = try? JSON(jsonString: html) else { throw SourceError.parseError(error: "[MangaDex] Error getting json data for `fetchChapterImages`") }
            let hash = try json.next("chapter").next("hash").getString()
            let baseURL = try json.next("baseUrl").getString()

            return try json.next("chapter").next("data").getArray().enumerated().compactMap { (index, c) throws -> SourceChapterImage in
                return SourceChapterImage(index: index, imageUrl: "\(baseURL)/data/\(hash)/\(try c.getString())")
            }
        } catch(let error) {
            debugPrint(error)
            throw error
        }
    }
    
    public func mangaUrl(mangaId: String) -> URL {
        return URL(string: "https://mangadex.org/title/\(mangaId)")!
    }
    
    public func checkUpdates(mangaIds: [String]) async throws {
        throw SourceError.notImplemented
    }
    
    // TODO: MangaDex still can't order manga by latest update, workaround is to fetch last 20 chapter and fetch associated manga (no grouped chapter update), so not for now, let hope it's fixed soon
    private func getMangaList(page: Int, query: String? = nil, limit: Int = 20) async throws -> SourcePaginatedSmallManga {
        let page = page < 1 ? 1 : page
        let offset = (page - 1) * limit;

        let html = try await fetchHtml(url: "\(baseUrl)/manga?limit=\(limit)&offset=\(offset)&includes[]=cover_art\((query != nil) ? "&\(query!)" : "")")
        guard let json = try? JSON(jsonString: html) else { throw SourceError.parseError(error: "[MangaDex] Error getting json data for `getMangaList`") }
        let dataOffset = try json.next("offset").getInt()
        let total = try json.next("total").getInt()
        
        let mangas = try json.next("data").getArray().map { d -> SourceSmallManga in
            let mangaId = try d.next("id").getString()
            let title = getMangaTitle(data: d)
            let cover = getCover(mangaId: mangaId, data: d)
            
            return SourceSmallManga(id: mangaId, title: title, thumbnailUrl: cover)
        }
        
        return SourcePaginatedSmallManga(mangas: mangas, hasNextPage: dataOffset < total)
    }
    
    private func getLatestManga(page: Int) async throws -> SourcePaginatedSmallManga {
        do {
            let page = page < 1 ? 1 : page
            let limit = 100
            let offset = limit * (page - 1)
            
            let html = try await fetchHtml(url: "\(baseUrl)/chapter?offset=\(offset)&limit=\(limit)&translatedLanguage[]=en&order[publishAt]=desc&includeFutureUpdates=0")
            guard let json = try? JSON(jsonString: html) else { throw SourceError.parseError(error: "[MangaDex] Error getting json data for `getLatestManga`")}
            let dataLimit = try json.next("limit").getInt()
            let dataOffset = try json.next("offset").getInt()
            let dataTotal = try json.next("total").getInt()

            let mangasIds = try json.next("data").getArray()
                .flatMap { try $0.next("relationships").getArray() }
                .filter { (try $0.next("type").getString()) == "manga" }
                .reduce(into: OrderedSet<String>()) { $0.append(try $1.next("id").getString()) }
            let mangaIdsQuery = mangasIds.map{ "ids[]=\($0)" }.joined(separator: "&")
            
            let list = try await getMangaList(page: 1, query: mangaIdsQuery, limit: mangasIds.count)
            
            let mangas = mangasIds.compactMap { mangaId in
                return list.mangas.first(where: { $0.id == mangaId })
            }
            
            return SourcePaginatedSmallManga(mangas: mangas, hasNextPage: dataOffset + dataLimit < dataTotal)
        } catch(let error) {
            debugPrint(error)
            throw error
        }
    }
    
    private func getCover(mangaId: String, data: JSON) -> String {
        let fileName = try? data.next("relationships").getArray().filter { (try? $0.next("type").getString()) == "cover_art" }.first?.next("attributes").next("fileName").getString()
        
        return fileName != nil ? "https://uploads.mangadex.org/covers/\(mangaId)/\(fileName!).256.jpg" : "https://i.imgur.com/6TrIues.png"
    }
    
    private func getMangaTitle(data: JSON) -> String {
        // If the title has a translated english title use it
        if let enTitle = try? data.next("attributes").next("title").next("en").getString(), !enTitle.isEmpty { return enTitle }
        if let altEnTitle = try? data.next("attributes").next("altTitles").getArray().first(where: { !(try $0.next("en").isNull) })?.next("en").getString(), !altEnTitle.isEmpty { return altEnTitle }

        // Most likely for Japanese title when original language is `ko`
        if let jaRo = try? data.next("attributes").next("title").next("ja-ro").getString(), !jaRo.isEmpty { return jaRo }
        if let jaTitle = try? data.next("attributes").next("title").next("ja").getString(), !jaTitle.isEmpty { return jaTitle }
        if let altJaRoTitle = try? data.next("attributes").next("altTitles").getArray().first(where: { !(try $0.next("ja-ro").isNull) })?.next("ja-ro").getString(), !altJaRoTitle.isEmpty { return altJaRoTitle }
        if let altJaTitle = try? data.next("attributes").next("altTitles").getArray().first(where: { !(try $0.next("ja").isNull) })?.next("ja").getString(), !altJaTitle.isEmpty { return altJaTitle }

        // Most likely for Korean title when original language is `ko`
        if let koTitle = try? data.next("attributes").next("title").next("ko").getString(), !koTitle.isEmpty { return koTitle }
        if let altkoTitle = try? data.next("attributes").next("altTitles").getArray().first(where: { !(try $0.next("ko").isNull) })?.next("ko").getString(), !altkoTitle.isEmpty { return altkoTitle }

        return "No title found"
    }
    
    private func fetchChapters(mangaId: String) async throws -> [SourceChapter] {
        var chapters = [SourceChapter]()
        var shouldRepeat = true
        var offset = 0
        
        repeat {
            let oldOffset = offset
            let html = try await fetchHtml(url: getChapterRequestUrl(mangaId: mangaId, offset: oldOffset))
            guard let json = try? JSON(jsonString: html) else { throw SourceError.parseError(error: "[MangaDex] error getting data for `fetchChapters` ") }

            let limit = (try? json.next("limit").getInt()) ?? 500
            let total = (try? json.next("total").getInt()) ?? 500
            
            chapters += try json.next("data").getArray().compactMap { d throws -> SourceChapter in
                let chapterId = try d.next("id").getString()
                let volume = (try? d.next("attributes").next("volume").getString()) ?? ""
                let volumeName = !volume.isEmpty ? "Volume \(volume) " : ""
                let chapter = (try? d.next("attributes").next("chapter").getString()) ?? ""
                let chapterName = !chapter.isEmpty ? chapter : "0"
                let chapterTitle = (try? d.next("attributes").next("title").getString()) ?? ""
                let chapterTitleName = !chapterTitle.isEmpty ? " - \(chapterTitle)" : ""
                let externalUrl = try? d.next("attributes").next("externalUrl").getString()
                
                let title = "\(volumeName)Chapter \(chapterName)\(chapterTitleName)"
                var date: Date {
                    guard let rawPublishAt = try? d.next("attributes").next("publishAt").getString() else { return Date.now }
                    guard let rawCreatedAt = try? d.next("attributes").next("createdAt").getString() else { return Date.now }
                    
                    do {
                        let publishAt = try Date(rawPublishAt, strategy: .iso8601)
                        let createdAt = try? Date(rawCreatedAt, strategy: .iso8601)
                        return publishAt > Date.now ? createdAt ?? Date.now : publishAt
                    } catch {
                        return Date.now
                    }
                }
                
                return SourceChapter(
                    name: title,
                    id: chapterId,
                    dateUpload: date,
                    externalUrl: externalUrl
                )
            }

            shouldRepeat = (limit + offset) < total
            offset += limit
        } while shouldRepeat
        
        return chapters
    }
    
    private func getChapterRequestUrl(mangaId: String, offset: Int = 0) -> String {
        "\(baseUrl)/manga/\(mangaId)/feed?includes[]=scanlation_group&includes[]=user&limit=500&offset=\(offset)&translatedLanguage[]=en&order[volume]=desc&order[chapter]=desc"
    }
    
    private func fetchHtml(url: String) async throws -> String {
        guard let url = URL(string: url) else { throw "Not a url: \(url)" }

        var req = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData)
        headers.forEach { key, value in
            req.setValue(value, forHTTPHeaderField: key)
        }

        let (data, _) = try await URLSession.shared.data(for: req)
        guard !data.isEmpty else { throw SourceError.websiteError }

        return String(decoding: data, as: UTF8.self)
    }
}
