import Foundation

public enum SourceError: Error {
    case parseError(error: String)
    case websiteError
    case fetchError
    case notImplemented
}

public enum SourceLang: String, CaseIterable {
    case fr = "French"
    case en = "English"
    case jp = "Japanese"
    case all = "All"
}

public enum SourceMangaCompletion: String, CaseIterable {
    case ongoing = "Ongoing"
    case complete = "Complete"
    case unknown = "Unknown"
}

public enum SourceMangaType: String, CaseIterable {
    case manga = "Manga"
    case manhua = "Manhua"
    case manhwa = "Manhwa"
    case doujinshi = "Doujinshi"
    case unknown = "Unknown"
}

public struct SourceManga: Identifiable, Equatable, Hashable {
    public var id: String
    public var title: String
    public var cover: URL
    public var genres: [String]
    public var authors: [String]
    public var alternateNames: [String]
    public var status: SourceMangaCompletion
    public var synopsis: String
    public var chapters: [SourceChapter]
    public var type: SourceMangaType
    
    public init(id: String, title: String, cover: URL, genres: [String], authors: [String], alternateNames: [String], status: SourceMangaCompletion, synopsis: String, chapters: [SourceChapter], type: SourceMangaType) {
        self.id = id
        self.title = title
        self.cover = cover
        self.genres = genres
        self.authors = authors
        self.alternateNames = alternateNames
        self.status = status
        self.synopsis = synopsis
        self.chapters = chapters
        self.type = type
    }
}

public struct SourceChapter: Identifiable, Equatable, Hashable {
    public var id: String
    public var name: String
    public var dateUpload: Date
    public var externalUrl: URL?
    public var chapter: Float
    public var volume: Float?
    public var subTitle: String?
    
    public init(id: String, name: String, dateUpload: Date, externalUrl: URL? = nil, chapter: Float, volume: Float? = nil, subTitle: String? = nil) {
        self.id = id
        self.name = name
        self.dateUpload = dateUpload
        self.externalUrl = externalUrl
        self.chapter = chapter
        self.volume = volume
        self.subTitle = subTitle
    }
}

public struct SourceChapterImage: Identifiable, Equatable, Hashable {
    public var id: URL { imageUrl }
    public var index: Int
    public var imageUrl: URL
    
    public init(index: Int, imageUrl: URL) {
        self.index = index
        self.imageUrl = imageUrl
    }
}

public struct SourceSmallManga: Identifiable, Equatable, Hashable {
    public var id: String
    public var title: String
    public var thumbnailUrl: URL
    
    public init(id: String, title: String, thumbnailUrl: URL) {
        self.id = id
        self.title = title
        self.thumbnailUrl = thumbnailUrl
    }
}

public enum SourceFetchType: String, CaseIterable, Identifiable {
    case latest = "Latest"
    case popular = "Popular"
    
    public var id: Self { self }
}

public typealias SourcePaginatedSmallManga = (mangas: [SourceSmallManga], hasNextPage: Bool)

public protocol Source {
    var name: String { get }
    var id: UUID { get }
    var versionNumber: Float { get }
    var updatedAt: Date { get }
    var lang: SourceLang { get }
    var icon: URL { get }
    var baseUrl: URL { get }
    var supportsLatest: Bool  { get }
    var headers: [String:String] { get }
    var nsfw: Bool { get }
    var deprecated: Bool { get }
    
    func fetchPopularManga(page: Int) async throws -> SourcePaginatedSmallManga
    func fetchLatestUpdates(page: Int) async throws -> SourcePaginatedSmallManga
    func fetchSearchManga(query: String, page: Int) async throws -> SourcePaginatedSmallManga
    func fetchMangaDetail(id: String) async throws -> SourceManga
    func fetchChapterImages(mangaId: String, chapterId: String) async throws -> [SourceChapterImage]
    func mangaUrl(mangaId: String) -> URL
    func checkUpdates(mangaIds: [String]) async throws -> Void
}

public protocol MultiSource: Source {
    init(baseUrl: URL, icon: URL, id: UUID, name: String)
}

extension Identifiable where Self: Source {}
extension Equatable where Self: Source {}
