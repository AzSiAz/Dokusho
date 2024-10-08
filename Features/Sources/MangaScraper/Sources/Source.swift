//
//  MangaSource.swift
//  Hanako
//
//  Created by Stephan Deumier on 30/12/2020.
//

import Foundation

public enum SourceError: Error {
    case parseError(error: String)
    case websiteError
    case fetchError
    case notImplemented
}

public enum SourceLang: String, CaseIterable, Sendable {
    case fr = "French"
    case en = "English"
    case jp = "Japanese"
    case all = "All"
}

public enum SourceMangaCompletion: String, CaseIterable, Sendable {
    case ongoing = "Ongoing"
    case complete = "Complete"
    case unknown = "Unknown"
}

public enum SourceMangaType: String, CaseIterable, Sendable {
    case manga = "Manga"
    case manhua = "Manhua"
    case manhwa = "Manhwa"
    case doujinshi = "Doujinshi"
    case unknown = "Unknown"
}

public struct SourceManga: Identifiable, Equatable, Hashable, Sendable {
    public var id: String
    public var title: String
    public var cover: String
    public var genres: [String]
    public var authors: [String]
    public var alternateNames: [String]
    public var status: SourceMangaCompletion
    public var synopsis: String
    public var chapters: [SourceChapter]
    public var type: SourceMangaType
}

public struct SourceChapter: Identifiable, Equatable, Hashable, Sendable {
    public var name: String
    public var id: String
    public var dateUpload: Date
    public var externalUrl: String?
}

public struct SourceChapterImage: Identifiable, Equatable, Hashable, Sendable {
    public var id = UUID()
    
    public var index: Int
    public var imageUrl: String
    
    public init(index: Int, imageUrl: String) {
        self.index = index
        self.imageUrl = imageUrl
    }
}

public struct SourceSmallManga: Identifiable, Equatable, Hashable, Sendable {
    public init(id: String, title: String, thumbnailUrl: String) {
        self.id = id
        self.title = title
        self.thumbnailUrl = thumbnailUrl
    }
    
    public var id: String
    public var title: String
    public var thumbnailUrl: String
}

public enum SourceFetchType: String, CaseIterable, Identifiable, Sendable {
    case latest = "Latest"
    case popular = "Popular"
    
    public var id: Self { self }
}

public typealias SourcePaginatedSmallManga = (mangas: [SourceSmallManga], hasNextPage: Bool)

public protocol Source: Sendable {
    var name: String { get }
    var id: UUID { get }
    var versionNumber: Float { get }
    var updatedAt: Date { get }
    var lang: SourceLang { get }
    var icon: String { get }
    var baseUrl: String { get }
    var supportsLatest: Bool  { get }
    var headers: [String:String] { get }
    var nsfw: Bool { get }
    
    func fetchPopularManga(page: Int) async throws -> SourcePaginatedSmallManga
    func fetchLatestUpdates(page: Int) async throws -> SourcePaginatedSmallManga
    func fetchSearchManga(query: String, page: Int) async throws -> SourcePaginatedSmallManga
    func fetchMangaDetail(id: String) async throws -> SourceManga
    func fetchChapterImages(mangaId: String, chapterId: String) async throws -> [SourceChapterImage]
    func mangaUrl(mangaId: String) -> URL
    func checkUpdates(mangaIds: [String]) async throws -> Void
}

public protocol MultiSource: Source {
    init(baseUrl: String, icon: String, id: UUID, name: String)
}

extension Identifiable where Self: Source {}
