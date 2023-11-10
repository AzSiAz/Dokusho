import Foundation

public enum SourceError: Error {
    case parseError(error: String)
    case websiteError
    case fetchError
    case notImplemented
}

public enum SourceLanguage: String, CaseIterable {
    case fr = "French"
    case en = "English"
    case jp = "Japanese"
    case all = "All"
}

public enum SourceSerieCompletion: String, CaseIterable {
    case ongoing = "Ongoing"
    case complete = "Complete"
    case unknown = "Unknown"
}

public enum SourceSerieType: String, CaseIterable {
    case manga = "Manga"
    case manhua = "Manhua"
    case manhwa = "Manhwa"
    case doujinshi = "Doujinshi"
    case unknown = "Unknown"
    case lightNovel = "Light Novel"
}

public struct SourceSerie: Identifiable, Equatable, Hashable {
    public var id: String
    public var title: String
    public var cover: URL
    public var genres: [String]
    public var authors: [String]
    public var alternateTitles: [String]
    public var status: SourceSerieCompletion
    public var synopsis: String
    public var chapters: [SourceChapter]
    public var type: SourceSerieType
    
    public init(id: String, title: String, cover: URL, genres: [String], authors: [String], alternateTitles: [String], status: SourceSerieCompletion, synopsis: String, chapters: [SourceChapter], type: SourceSerieType) {
        self.id = id
        self.title = title
        self.cover = cover
        self.genres = genres
        self.authors = authors
        self.alternateTitles = alternateTitles
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

public struct SourceSmallSerie: Identifiable, Equatable, Hashable {
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

public typealias SourcePaginatedSmallSerie = (data: [SourceSmallSerie], hasNextPage: Bool)

public protocol Source {
    var name: String { get }
    var id: UUID { get }
    var versionNumber: Float { get }
    var updatedAt: Date { get }
    var language: SourceLanguage { get }
    var icon: URL { get }
    var baseUrl: URL { get }
    var supportsLatest: Bool  { get }
    var headers: [String:String] { get }
    var nsfw: Bool { get }
    var deprecated: Bool { get }
    
    func fetchPopularSerie(page: Int) async throws -> SourcePaginatedSmallSerie
    func fetchLatestUpdates(page: Int) async throws -> SourcePaginatedSmallSerie
    func fetchSearchSerie(query: String, page: Int) async throws -> SourcePaginatedSmallSerie
    func fetchSerieDetail(serieId: String) async throws -> SourceSerie
    func fetchChapterImages(serieId: String, chapterId: String) async throws -> [SourceChapterImage]
    func serieUrl(serieId: String) -> URL
    func checkUpdates(serieIds: [String]) async throws -> Void
}

public protocol MultiSource: Source {
    init(baseUrl: URL, icon: URL, id: UUID, name: String)
}

extension Identifiable where Self: Source {}
extension Equatable where Self: Source {}
