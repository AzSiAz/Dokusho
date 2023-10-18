import Foundation

#if (DEBUG)
public struct MockSource: Source {
    public static var mock: Source = Self()
    
    private(set) public var name: String = "MockSource"
    private(set) public var id: UUID = UUID(uuidString: "3599756d-8fa0-4ca2-aafc-096c3d776ae2")!
    private(set) public var versionNumber: Float = 1
    private(set) public var updatedAt: Date = .now
    private(set) public var language: SourceLanguage = .all
    private(set) public var icon: URL = URL(string: "https://www.google.fr/favicon.ico")!
    private(set) public var baseUrl: URL = URL(string: "https://www.google.fr/")!
    private(set) public var supportsLatest: Bool = true
    private(set) public var headers = [String : String]()
    private(set) public var nsfw: Bool = true
    private(set) public var deprecated: Bool = false
    
    private let waitFor: Duration = .seconds(0.5)
    
    public func fetchPopularSerie(page: Int) async throws -> SourcePaginatedSmallSerie {
        try await Task.sleep(for: waitFor)

        return SourcePaginatedSmallSerie(
            data: Array(repeating: (), count: 100).enumerated().map {
                SourceSmallSerie(id: "ID\($0.offset)", title: "ID \($0.offset)", thumbnailUrl: URL(string: "http://localhost:3000/manga/id-\($0.offset).png")!)
            },
            hasNextPage: page == 1 ? true : false
        )
    }
    
    public func fetchLatestUpdates(page: Int) async throws -> SourcePaginatedSmallSerie {
        try await Task.sleep(for: waitFor)

        return SourcePaginatedSmallSerie(
            data: Array(repeating: (), count: 100).enumerated().map {
                SourceSmallSerie(id: "ID\($0.offset)", title: "ID \($0.offset)", thumbnailUrl: URL(string: "http://localhost:3000/manga/id-\($0.offset).png")!)
            }.shuffled(),
            hasNextPage: page == 1 ? true : false
        )
    }
    
    public func fetchSearchSerie(query: String, page: Int) async throws -> SourcePaginatedSmallSerie {
        try await Task.sleep(for: waitFor)

        return SourcePaginatedSmallSerie(
            data: Array(repeating: (), count: 100).enumerated().map {
                SourceSmallSerie(id: "ID\($0.offset)", title: "ID \($0.offset)", thumbnailUrl: URL(string: "http://localhost:3000/manga/id-\($0.offset).png")!)
            },
            hasNextPage: page == 1 ? true : false
        )
    }
    
    public func fetchSerieDetail(serieId: String) async throws -> SourceSerie {
        try await Task.sleep(for: waitFor)

        return SourceSerie(
            id: serieId,
            title: "ID \(serieId)",
            cover: URL(string: "http://localhost:3000/manga/\(serieId).png")!,
            genres: ["Shonen", "Seinen", "Drama"],
            authors: ["Lol number 1", "Lol number 2"],
            alternateTitles: ["_ID \(serieId)_"],
            status: .ongoing,
            synopsis: "Lorem ipsum Lorem ipsum Lorem ipsum Lorem ipsum Lorem ipsum Lorem ipsum Lorem ipsum Lorem ipsum Lorem ipsum Lorem ipsum Lorem ipsum Lorem ipsum Lorem ipsum Lorem ipsum",
            chapters: Array(repeating: (), count: 100).enumerated().map {
                SourceChapter(id: "\($0.offset)", name: "lol \($0.offset)", dateUpload: .distantPast, chapter: Float($0.offset), volume: Float($0.offset))
            },
            type: .manga
        )
    }
    
    public func fetchChapterImages(serieId: String, chapterId: String) async throws -> [SourceChapterImage] {
        try await Task.sleep(for: waitFor)

        return Array(repeating: (), count: 100).enumerated().map {
            SourceChapterImage(index: $0.offset, imageUrl: URL(string: "http://localhost:3000/manga/\(serieId)/\(chapterId)/\($0.offset).png")!)
        }
    }
    
    public func serieUrl(serieId: String) -> URL {
        return URL(string: "http://localhost:3000/manga/\(serieId)")!
    }
    
    public func checkUpdates(serieIds: [String]) async throws {
        return
    }
}
#endif
