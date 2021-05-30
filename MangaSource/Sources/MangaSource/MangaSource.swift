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

public enum LangSource: String {
    case fr = "French"
    case en = "English"
    case jp = "Japanese"
}

public enum MangaCompletion: String {
    case ongoing = "Ongoing"
    case complete = "Complete"
    case unknown = "Unknown"
}

public enum MangaType: String {
    case webtoon = "WebToon"
    case japanese = "Japanese"
    case chinese = "Chinese"
}

public struct Manga {
    var id: String
    var title: String
    var thumbnailUrl: String
    var genres: [String]
    var authors: [String]
    var alternateNames: [String]
    var status: MangaCompletion
    var description: String
    var chapters: [Chapter]
    var type: MangaType = .japanese
}

struct Chapter: Identifiable, Equatable, Hashable {
    var name: String
    var id: String
    var dateUpload: Date
}

struct ChapterImage: Identifiable, Equatable, Hashable {
    var id = UUID()
    
    var index: Int
    var imageUrl: String
    var status: String? = nil
}

struct SmallManga: Identifiable, Equatable, Hashable {
    var id: String
    var title: String
    var thumbnailUrl: String
}

public enum SourceFetchType: String {
    case latest = "Latest"
    case popular = "Popular"
}

typealias PaginatedSmallManga = (mangas: [SmallManga], hasNextPage: Bool)

protocol Source {
    var name: String { get }
    var id: String { get }
    var versionNumber: Float { get }
    var updatedAt: Date { get }
    var lang: LangSource { get }
    var icon: String { get }
    var baseUrl: String { get }
    var supportsLatest: Bool  { get }
    var headers: HTTPHeaders { get }
    
    func fetchPopularManga(page: Int, completion: @escaping (Result<PaginatedSmallManga, SourceError>) -> Void)
    func fetchLatestUpdates(page: Int, completion: @escaping (Result<PaginatedSmallManga, SourceError>) -> Void)
    func fetchSearchManga(query: String, page: Int, completion: @escaping (Result<PaginatedSmallManga, SourceError>) -> Void)
    func fetchMangaDetail(id: String, completion: @escaping (Result<Manga, SourceError>) -> Void)
    func fetchChapterImages(mangaId: String, chapterId: String, completion: @escaping (Result<[ChapterImage], SourceError>) -> Void)
    func mangaUrl(mangaId: String) -> URL
}

struct MiniSource: Identifiable, Hashable {
    var id: Int
    var sourceIndex: Int
    var name: String
    var lang: LangSource
    var icon: String
}
