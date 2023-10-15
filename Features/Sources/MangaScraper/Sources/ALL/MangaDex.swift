import Foundation
import JAYSON
import Collections

public struct MangaDexSource: Source {
    public static let mangadex: Source = Self()
    
    private(set) public var name: String = "MangaDex"
    private(set) public var id: UUID = UUID(uuidString: "3599756d-8fa0-4ca2-aafc-096c3d776ae1")!
    private(set) public var versionNumber: Float = 1.0
    private(set) public var updatedAt: Date = Date.from(year: 2022, month: 01, day: 02)
    private(set) public var language: SourceLanguage = .all
    private(set) public var icon: URL = URL(string: "https://mangadex.org/favicon.ico")!
    private(set) public var baseUrl: URL = URL(string: "https://api.mangadex.org")!
    private(set) public var supportsLatest: Bool = true
    private(set) public var headers = [String : String]()
    private(set) public var nsfw: Bool = true
    private(set) public var deprecated: Bool = false
    
    public func fetchPopularSerie(page: Int) async throws -> SourcePaginatedSmallSerie {
        return try await getMangaList(page: page, query: "order[followedCount]=desc")
    }
    
    public func fetchLatestUpdates(page: Int) async throws -> SourcePaginatedSmallSerie {
        return try await getLatestManga(page: page)
    }
    
    public func fetchSearchSerie(query: String, page: Int) async throws -> SourcePaginatedSmallSerie {
        return try await getMangaList(page: page, query: "title=\(query.replacingOccurrences(of: " ", with: "%20"))")
    }
    
    public func fetchSerieDetail(serieId: String) async throws -> SourceSerie {
        do {
            let html = try await fetchHtml(url: "\(baseUrl)/manga/\(serieId)?&includes[]=author&includes[]=artist&includes[]=cover_art")
            guard let json = try? JSON(jsonString: html).next("data") else { throw SourceError.parseError(error: "[MangaDex] Error getting json data for `fetchMangaDetail`") }

            let title = getMangaTitle(data: json)
            let cover = getCover(id: serieId, data: json)
            let synopsis = (try? json.next("attributes").next("description").next("en").getString()) ?? "No synopsis found"
            let genres = try json.next("attributes").next("tags").getArray().compactMap { try? $0.next("attributes").next("name").next("en").getString() }
            let authors = try json.next("relationships").getArray().filter { (try? $0.next("type").getString()) == "author" }.compactMap { try? $0.next("attributes").next("name").getString() }
            let artists = try json.next("relationships").getArray().filter { (try? $0.next("type").getString()) == "artist" }.compactMap { try? $0.next("attributes").next("name").getString() }
            let altTitle = try json.next("attributes").next("altTitles").getArray().compactMap { try? $0.next("en").getString() }
            
            var status: SourceSerieCompletion {
                let status = try? json.next("attributes").next("status").getString()
                switch status {
                case "completed": return SourceSerieCompletion.complete
                case "ongoing": return SourceSerieCompletion.ongoing
                default: return SourceSerieCompletion.unknown
                }
            }
            
            var type: SourceSerieType {
                let found = try? json.next("attributes").next("originalLanguage").getString()
                switch found {
                case "ko": return SourceSerieType.manhwa
                case "jp": return SourceSerieType.manga
                case "zh": return SourceSerieType.manhua
                default: return SourceSerieType.unknown
                }
            }
            
            return SourceSerie(
                id: serieId,
                title: title,
                cover: cover,
                genres: genres,
                authors: Array(Set(authors + artists)),
                alternateTitles: altTitle,
                status: status,
                synopsis: synopsis,
                chapters: try await fetchChapters(id: serieId),
                type: type
            )
        } catch(let error) {
            debugPrint(error)
            throw error
        }
    }
    
    public func fetchChapterImages(serieId: String, chapterId: String) async throws -> [SourceChapterImage] {
        do {
            let html = try await fetchHtml(url: "https://api.mangadex.org/at-home/server/\(chapterId)?forcePort443=false")
            guard let json = try? JSON(jsonString: html) else { throw SourceError.parseError(error: "[MangaDex] Error getting json data for `fetchChapterImages`") }
            let hash = try json.next("chapter").next("hash").getString()
            let baseURL = try json.next("baseUrl").getString()

            return try json.next("chapter").next("data").getArray().enumerated().compactMap { (index, c) throws -> SourceChapterImage in
                return SourceChapterImage(index: index, imageUrl: URL(string: "\(baseURL)/data/\(hash)/\(try c.getString())")!)
            }
        } catch(let error) {
            debugPrint(error)
            throw error
        }
    }
    
    public func serieUrl(serieId: String) -> URL {
        return URL(string: "https://mangadex.org/title/\(serieId)")!
    }
    
    public func checkUpdates(serieIds: [String]) async throws {
        throw SourceError.notImplemented
    }
    
    // TODO: MangaDex still can't order manga by latest update, workaround is to fetch last X chapters and fetch associated manga (no grouped chapter update), so not for now, let hope it's fixed soon
    private func getMangaList(page: Int, query: String? = nil, limit: Int = 20) async throws -> SourcePaginatedSmallSerie {
        let page = page < 1 ? 1 : page
        let offset = (page - 1) * limit;

        let html = try await fetchHtml(url: "\(baseUrl)/manga?limit=\(limit)&offset=\(offset)&includes[]=cover_art\((query != nil) ? "&\(query!)" : "")")
        guard let json = try? JSON(jsonString: html) else { throw SourceError.parseError(error: "[MangaDex] Error getting json data for `getMangaList`") }
        let dataOffset = try json.next("offset").getInt()
        let total = try json.next("total").getInt()
        
        let mangas = try json.next("data").getArray().map { d -> SourceSmallSerie in
            let mangaId = try d.next("id").getString()
            let title = getMangaTitle(data: d)
            let cover = getCover(id: mangaId, data: d)
            
            return SourceSmallSerie(id: mangaId, title: title, thumbnailUrl: cover)
        }
        
        return SourcePaginatedSmallSerie(data: mangas, hasNextPage: dataOffset < total)
    }
    
    private func getLatestManga(page: Int) async throws -> SourcePaginatedSmallSerie {
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
                return list.data.first(where: { $0.id == mangaId })
            }
            
            return SourcePaginatedSmallSerie(data: mangas, hasNextPage: dataOffset + dataLimit < dataTotal)
        } catch(let error) {
            debugPrint(error)
            throw error
        }
    }
    
    private func getCover(id: String, data: JSON) -> URL {
        let fileName = try? data.next("relationships").getArray().filter { (try? $0.next("type").getString()) == "cover_art" }.first?.next("attributes").next("fileName").getString()
        
        let link = fileName != nil ? "https://uploads.mangadex.org/covers/\(id)/\(fileName!).256.jpg" : "https://i.imgur.com/6TrIues.png"
        
        return URL(string: link)!
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
    
    private func fetchChapters(id: String) async throws -> [SourceChapter] {
        var chapters = [SourceChapter]()
        var shouldRepeat = true
        var offset = 0
        
        repeat {
            let oldOffset = offset
            let html = try await fetchHtml(url: getChapterRequestUrl(id: id, offset: oldOffset))
            guard let json = try? JSON(jsonString: html) else { throw SourceError.parseError(error: "[MangaDex] error getting data for `fetchChapters` ") }

            let limit = (try? json.next("limit").getInt()) ?? 500
            let total = (try? json.next("total").getInt()) ?? 500
            
            chapters += try json.next("data").getArray().enumerated().compactMap { d throws -> SourceChapter in
                let chapterId = try d.element.next("id").getString()
                let volume = (try? d.element.next("attributes").next("volume").getString()) ?? ""
                let volumeName = !volume.isEmpty ? "Volume \(volume) " : ""
                let chapter = (try? d.element.next("attributes").next("chapter").getString()) ?? ""
                let chapterName = !chapter.isEmpty ? chapter : "0"
                let chapterTitle = (try? d.element.next("attributes").next("title").getString()) ?? ""
                let chapterTitleName = !chapterTitle.isEmpty ? " - \(chapterTitle)" : ""
                let externalUrl = try? d.element.next("attributes").next("externalUrl").getString() 
                
                let title = "\(volumeName)Chapter \(chapterName)\(chapterTitleName)"
                var date: Date {
                    guard let rawPublishAt = try? d.element.next("attributes").next("publishAt").getString() else { return Date.now }
                    guard let rawCreatedAt = try? d.element.next("attributes").next("createdAt").getString() else { return Date.now }
                    
                    do {
                        let publishAt = try Date(rawPublishAt, strategy: .iso8601)
                        let createdAt = try? Date(rawCreatedAt, strategy: .iso8601)
                        return publishAt > Date.now ? createdAt ?? Date.now : publishAt
                    } catch {
                        return Date.now
                    }
                }
                
                return SourceChapter(
                    id: chapterId,
                    name: title,
                    dateUpload: date,
                    externalUrl: URL(string: externalUrl ?? ""),
                    chapter: chapter.floatValue ?? 0,
                    volume: volume.floatValue ?? 0
                )
            }

            shouldRepeat = (limit + offset) < total
            offset += limit
        } while shouldRepeat
        
        return chapters
    }
    
    private func getChapterRequestUrl(id: String, offset: Int = 0) -> String {
        "\(baseUrl)/manga/\(id)/feed?includes[]=scanlation_group&includes[]=user&limit=500&offset=\(offset)&translatedLanguage[]=en&order[volume]=desc&order[chapter]=desc"
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
