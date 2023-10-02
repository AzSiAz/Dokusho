import Foundation

#if (DEBUG)
public struct MockSource: Source {
    static var mock: Source = Self()
    
    private(set) public var name: String = "MockSource"
    private(set) public var id: UUID = UUID(uuidString: "3599756d-8fa0-4ca2-aafc-096c3d776ae2")!
    private(set) public var versionNumber: Float = 1
    private(set) public var updatedAt: Date = .now
    private(set) public var lang: SourceLang = .all
    private(set) public var icon: URL = URL(string: "https://www.google.fr/favicon.ico")!
    private(set) public var baseUrl: URL = URL(string: "https://www.google.fr/")!
    private(set) public var supportsLatest: Bool = true
    private(set) public var headers = [String : String]()
    private(set) public var nsfw: Bool = true
    private(set) public var deprecated: Bool = false
    
    public func fetchPopularManga(page: Int) async throws -> SourcePaginatedSmallManga {
        return SourcePaginatedSmallManga(mangas: [
            SourceSmallManga(id: "ID1", title: "ID 1", thumbnailUrl: URL(string: "http://localhost:3000/manga/id-1.png")!),
            SourceSmallManga(id: "ID2", title: "ID 2", thumbnailUrl: URL(string: "http://localhost:3000/manga/id-2.png")!),
            SourceSmallManga(id: "ID3", title: "ID 3", thumbnailUrl: URL(string: "http://localhost:3000/manga/id-3.png")!),
            SourceSmallManga(id: "ID4", title: "ID 4", thumbnailUrl: URL(string: "http://localhost:3000/manga/id-4.png")!),
            SourceSmallManga(id: "ID5", title: "ID 5", thumbnailUrl: URL(string: "http://localhost:3000/manga/id-5.png")!),
            SourceSmallManga(id: "ID6", title: "ID 6", thumbnailUrl: URL(string: "http://localhost:3000/manga/id-6.png")!),
        ], hasNextPage: page == 1 ? true : false)
    }
    
    public func fetchLatestUpdates(page: Int) async throws -> SourcePaginatedSmallManga {
        return SourcePaginatedSmallManga(mangas: [
            SourceSmallManga(id: "ID6", title: "ID 6", thumbnailUrl: URL(string: "http://localhost:3000/manga/id-6.png")!),
            SourceSmallManga(id: "ID5", title: "ID 5", thumbnailUrl: URL(string: "http://localhost:3000/manga/id-5.png")!),
            SourceSmallManga(id: "ID4", title: "ID 4", thumbnailUrl: URL(string: "http://localhost:3000/manga/id-4.png")!),
            SourceSmallManga(id: "ID3", title: "ID 3", thumbnailUrl: URL(string: "http://localhost:3000/manga/id-3.png")!),
            SourceSmallManga(id: "ID2", title: "ID 2", thumbnailUrl: URL(string: "http://localhost:3000/manga/id-2.png")!),
            SourceSmallManga(id: "ID1", title: "ID 1", thumbnailUrl: URL(string: "http://localhost:3000/manga/id-1.png")!),
        ], hasNextPage: page == 1 ? true : false)
    }
    
    public func fetchSearchManga(query: String, page: Int) async throws -> SourcePaginatedSmallManga {
        return SourcePaginatedSmallManga(mangas: [
            SourceSmallManga(id: "ID6", title: "ID 6", thumbnailUrl: URL(string: "http://localhost:3000/manga/id-6.png")!),
            SourceSmallManga(id: "ID5", title: "ID 5", thumbnailUrl: URL(string: "http://localhost:3000/manga/id-5.png")!),
            SourceSmallManga(id: "ID4", title: "ID 4", thumbnailUrl: URL(string: "http://localhost:3000/manga/id-4.png")!),
            SourceSmallManga(id: "ID3", title: "ID 3", thumbnailUrl: URL(string: "http://localhost:3000/manga/id-3.png")!),
            SourceSmallManga(id: "ID2", title: "ID 2", thumbnailUrl: URL(string: "http://localhost:3000/manga/id-2.png")!),
            SourceSmallManga(id: "ID1", title: "ID 1", thumbnailUrl: URL(string: "http://localhost:3000/manga/id-1.png")!),
        ], hasNextPage: page == 1 ? true : false)
    }
    
    public func fetchMangaDetail(id: String) async throws -> SourceManga {
        return SourceManga(
            id: id,
            title: "ID \(id)",
            cover: URL(string: "http://localhost:3000/manga/\(id).png")!,
            genres: ["Shonen", "Seinen", "Drama"],
            authors: ["Lol number 1", "Lol number 2"],
            alternateNames: ["_ID \(id)_"],
            status: .ongoing,
            synopsis: "Lorem ipsum Lorem ipsum Lorem ipsum Lorem ipsum Lorem ipsum Lorem ipsum Lorem ipsum Lorem ipsum Lorem ipsum Lorem ipsum Lorem ipsum Lorem ipsum Lorem ipsum Lorem ipsum",
            chapters: [
                SourceChapter(id: "3", name: "lol 3", dateUpload: .distantPast, chapter: 3),
                SourceChapter(id: "3", name: "lol 3", dateUpload: .distantPast, chapter: 2),
                SourceChapter(id: "2", name: "lol 2", dateUpload: .distantPast, chapter: 1),
                SourceChapter(id: "1", name: "lol 1", dateUpload: .distantPast, chapter: 0)
            ],
            type: .manga
        )
    }
    
    public func fetchChapterImages(mangaId: String, chapterId: String) async throws -> [SourceChapterImage] {
        return []
    }
    
    public func mangaUrl(mangaId: String) -> URL {
        return URL(string: "http://localhost:3000/manga/\(mangaId)")!
    }
    
    public func checkUpdates(mangaIds: [String]) async throws {
        return
    }
}
#endif
