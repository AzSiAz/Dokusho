//
//  MangaSource.swift
//  Hanako
//
//  Created by Stephan Deumier on 30/12/2020.
//

import Foundation
import Alamofire

public enum SourceError: Error {
    case parseError
    case websiteError
    case fetchError
}

public enum SourceLang: String {
    case fr = "French"
    case en = "English"
    case jp = "Japanese"
}

public enum SourceMangaCompletion: String {
    case ongoing = "Ongoing"
    case complete = "Complete"
    case unknown = "Unknown"
}

public enum SourceMangaType: String {
    case webtoon = "WebToon"
    case japanese = "Japanese"
    case chinese = "Chinese"
}

public struct SourceManga: Identifiable, Equatable, Hashable {
    public var id: String
    public var title: String
    public var thumbnailUrl: String
    public var genres: [String]
    public var authors: [String]
    public var alternateNames: [String]
    public var status: SourceMangaCompletion
    public var description: String
    public var chapters: [SourceChapter]
    public var type: SourceMangaType = .japanese
}

public struct SourceChapter: Identifiable, Equatable, Hashable {
    public var name: String
    public var id: String
    public var dateUpload: Date
}

public struct SourceChapterImage: Identifiable, Equatable, Hashable {
    public var id = UUID()
    
    public var index: Int
    public var imageUrl: String
}

public struct SourceSmallManga: Identifiable, Equatable, Hashable {
    public var id: String
    public var title: String
    public var thumbnailUrl: String
}

public enum SourceFetchType: String {
    case latest = "Latest"
    case popular = "Popular"
}

public typealias SourcePaginatedSmallManga = (mangas: [SourceSmallManga], hasNextPage: Bool)

public typealias SourcePaginatedSmallMangaHandler = (Result<SourcePaginatedSmallManga, SourceError>) -> Void

public typealias SourceMangaDetailHandler = (Result<SourceManga, SourceError>) -> Void

public typealias SourceChapterImagesHandler = (Result<[SourceChapterImage], SourceError>) -> Void

public protocol Source {
    var name: String { get }
    var id: Int { get }
    var versionNumber: Float { get }
    var updatedAt: Date { get }
    var lang: SourceLang { get }
    var icon: String { get }
    var baseUrl: String { get }
    var supportsLatest: Bool  { get }
    var headers: HTTPHeaders { get }
    
    func fetchPopularManga(page: Int, completion: @escaping SourcePaginatedSmallMangaHandler)
    func fetchLatestUpdates(page: Int, completion: @escaping SourcePaginatedSmallMangaHandler)
    func fetchSearchManga(query: String, page: Int, completion: @escaping SourcePaginatedSmallMangaHandler)
    func fetchMangaDetail(id: String, completion: @escaping SourceMangaDetailHandler)
    func fetchChapterImages(mangaId: String, chapterId: String, completion: @escaping SourceChapterImagesHandler)
    func mangaUrl(mangaId: String) -> URL
}
