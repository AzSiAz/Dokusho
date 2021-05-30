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

public struct SourceManga {
    var id: String
    var title: String
    var thumbnailUrl: String
    var genres: [String]
    var authors: [String]
    var alternateNames: [String]
    var status: SourceMangaCompletion
    var description: String
    var chapters: [SourceChapter]
    var type: SourceMangaType = .japanese
}

struct SourceChapter: Identifiable, Equatable, Hashable {
    var name: String
    var id: String
    var dateUpload: Date
}

struct SourceChapterImage: Identifiable, Equatable, Hashable {
    var id = UUID()
    
    var index: Int
    var imageUrl: String
}

struct SourceSmallManga: Identifiable, Equatable, Hashable {
    var id: String
    var title: String
    var thumbnailUrl: String
}

public enum SourceFetchType: String {
    case latest = "Latest"
    case popular = "Popular"
}

typealias SourcePaginatedSmallManga = (mangas: [SourceSmallManga], hasNextPage: Bool)

protocol Source {
    var name: String { get }
    var id: String { get }
    var versionNumber: Float { get }
    var updatedAt: Date { get }
    var lang: SourceLang { get }
    var icon: String { get }
    var baseUrl: String { get }
    var supportsLatest: Bool  { get }
    var headers: HTTPHeaders { get }
    
    func fetchPopularManga(page: Int, completion: @escaping (Result<SourcePaginatedSmallManga, SourceError>) -> Void)
    func fetchLatestUpdates(page: Int, completion: @escaping (Result<SourcePaginatedSmallManga, SourceError>) -> Void)
    func fetchSearchManga(query: String, page: Int, completion: @escaping (Result<SourcePaginatedSmallManga, SourceError>) -> Void)
    func fetchMangaDetail(id: String, completion: @escaping (Result<SourceManga, SourceError>) -> Void)
    func fetchChapterImages(mangaId: String, chapterId: String, completion: @escaping (Result<[SourceChapterImage], SourceError>) -> Void)
    func mangaUrl(mangaId: String) -> URL
}
