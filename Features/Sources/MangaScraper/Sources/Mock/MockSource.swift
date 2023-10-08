import Foundation

#if (DEBUG)
public struct MockSource: Source {
    public static var mock: Source = Self()
    
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
        return SourcePaginatedSmallManga(
            mangas: Array(repeating: (), count: 100).enumerated().map {
                SourceSmallManga(id: "ID\($0.offset)", title: "ID \($0.offset)", thumbnailUrl: URL(string: "http://localhost:3000/manga/id-\($0.offset).png")!)
            },
            hasNextPage: page == 1 ? true : false
        )
    }
    
    public func fetchLatestUpdates(page: Int) async throws -> SourcePaginatedSmallManga {
        return SourcePaginatedSmallManga(
            mangas: Array(repeating: (), count: 100).enumerated().map {
                SourceSmallManga(id: "ID\($0.offset)", title: "ID \($0.offset)", thumbnailUrl: URL(string: "http://localhost:3000/manga/id-\($0.offset).png")!)
            },
            hasNextPage: page == 1 ? true : false
        )
    }
    
    public func fetchSearchManga(query: String, page: Int) async throws -> SourcePaginatedSmallManga {
        return SourcePaginatedSmallManga(
            mangas: Array(repeating: (), count: 100).enumerated().map {
                SourceSmallManga(id: "ID\($0.offset)", title: "ID \($0.offset)", thumbnailUrl: URL(string: "http://localhost:3000/manga/id-\($0.offset).png")!)
            },
            hasNextPage: page == 1 ? true : false
        )
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
            chapters: Array(repeating: (), count: 100).enumerated().map {
                SourceChapter(id: "\($0.offset)", name: "lol \($0.offset)", dateUpload: .distantPast, chapter: 100)
            },
            type: .manga
        )
    }
    
    public func fetchChapterImages(mangaId: String, chapterId: String) async throws -> [SourceChapterImage] {
        return Array(repeating: (), count: 100).enumerated().map {
            SourceChapterImage(index: $0.offset, imageUrl: URL(string: "http://localhost:3000/manga/\(mangaId)/\(chapterId)/\($0.offset).png")!)
        }
    }
    
    public func mangaUrl(mangaId: String) -> URL {
        return URL(string: "http://localhost:3000/manga/\(mangaId)")!
    }
    
    public func checkUpdates(mangaIds: [String]) async throws {
        return
    }
}
#endif
