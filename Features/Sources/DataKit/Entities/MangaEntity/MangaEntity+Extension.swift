//
//  File.swift
//  
//
//  Created by Stephan Deumier on 30/06/2022.
//

import Foundation
import CoreData
import MangaScraper


@objc
public enum MangaEntityStatus: Int16 {
    case ongoing, complete, unknown
    
    func getText() -> String {
        switch self {
        case .ongoing: return "Ongoing"
        case .complete: return "Complete"
        case .unknown: return "Unknown"
        }
    }
    
    static func from(status: SourceMangaCompletion) -> Self {
        switch status {
        case .unknown: return .unknown
        case .complete: return .complete
        case .ongoing: return .ongoing
        }
    }
}

@objc
public enum MangaEntityType: Int16 {
    case manga, manhua, manhwa, unknown

    func getText() -> String {
        switch self {
        case .manga: return "Manga"
        case .manhua: return "Manhua"
        case .manhwa: return "Manhwa"
        case .unknown: return "Unknown"
        }
    }
    
    static func from(type: SourceMangaType) -> Self {
        switch type {
        case .doujinshi, .manga: return .manga
        case .manhua: return .manhua
        case .manhwa: return .manhwa
        case .unknown: return .unknown
        }
    }
}

extension MangaEntity {
    static func from(in ctx: NSManagedObjectContext, with data: SourceManga, scraperId: UUID) -> MangaEntity {
        let entity = MangaEntity(context: ctx)
        entity.mangaId = data.id
        entity.title = data.title
        entity.cover = URL(string: data.cover)!
        entity.synopsis = data.synopsis
        entity.type = .from(type: data.type)
        entity.status = .from(status: data.status)
        entity.unreadChapters = Int16(data.chapters.count)
        entity.readChapters = 0
        entity.scraperId = scraperId
        entity.alternatesTitles = AlternateTitleEntity.from(ctx: ctx, titles: data.alternateNames, mangaId: data.id)
//        self.genres = data.genres
//        self.authors = data.authors
//        self.artists = data.authors

        return entity
    }
}
