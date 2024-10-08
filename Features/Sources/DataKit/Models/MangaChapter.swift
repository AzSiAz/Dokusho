//
//  Chapter.swift
//  Dokusho
//
//  Created by Stef on 22/12/2021.
//

import Foundation
@preconcurrency import GRDB
import MangaScraper

public enum ChapterStatusHistory: String, Sendable {
    case all = "Update", read = "Read"
}

public enum ChapterStatusFilter: String, Sendable {
    case all, unread
    
    static func toggle(value: Self) -> Self {
        if value == .all {
            return .unread
        }
        else {
            return .all
        }
    }
    
}

public enum ChapterStatus: String, CaseIterable, Codable, DatabaseValueConvertible, Sendable {
    case unread, read
    
    func inverse() -> ChapterStatus {
        switch self {
        case .unread:
            return .read
        case .read:
            return .unread
        }
    }
}

public struct MangaChapter: Identifiable, Equatable, Codable, Sendable {
    public var id: String
    public var chapterId: String
    public var title: String
    public var dateSourceUpload: Date
    public var position: Int
    public var readAt: Date?
    public var status: ChapterStatus
    public var mangaId: UUID
    public var externalUrl: String?
    
    public var isUnread: Bool {
        return status != .read
    }
    
    public init(from data: SourceChapter, position: Int, mangaId: UUID, scraperId: UUID) {
        self.id = "\(scraperId)@@\(data.id)"
        self.chapterId = data.id
        self.title = data.name
        self.dateSourceUpload = data.dateUpload
        self.position = position
        self.mangaId = mangaId
        self.status = .unread
        self.externalUrl = data.externalUrl
    }
}

extension MangaChapter: FetchableRecord, PersistableRecord {}

extension MangaChapter: TableRecord {
    public static let manga = belongsTo(Manga.self)
    public static let scraper = hasOne(Scraper.self, through: manga, using: Manga.scraper)

    public enum Columns {
        public static let id = Column(CodingKeys.id)
        public static let chapterId = Column(CodingKeys.chapterId)
        public static let title = Column(CodingKeys.title)
        public static let dateSourceUpload = Column(CodingKeys.dateSourceUpload)
        public static let position = Column(CodingKeys.position)
        public static let readAt = Column(CodingKeys.readAt)
        public static let status = Column(CodingKeys.status)
        public static let mangaId = Column(CodingKeys.mangaId)
        public static let externalUrl = Column(CodingKeys.externalUrl)
    }
    
    public static let databaseSelection: [SQLSelectable] = [
        Columns.id,
        Columns.chapterId,
        Columns.title,
        Columns.dateSourceUpload,
        Columns.position,
        Columns.readAt,
        Columns.status,
        Columns.mangaId,
        Columns.externalUrl
    ]
}

public extension DerivableRequest where RowDecoder == MangaChapter {
    func forMangaId(_ mangaId: UUID) -> Self {
        filter(RowDecoder.Columns.mangaId == mangaId)
    }
    
    func forMangaId(_ mangaId: String, _ scraperId: UUID) -> Self {
        joining(required: RowDecoder.manga.forMangaId(mangaId, scraperId))
    }

    func forChapterStatus(_ status: ChapterStatus) -> Self {
        filter(RowDecoder.Columns.status == status)
    }
    
    func orderHistoryAll() -> Self {
        order(RowDecoder.Columns.dateSourceUpload.desc, MangaChapter.Columns.mangaId, MangaChapter.Columns.position.asc)
    }
    
    func orderHistoryRead() -> Self {
        order(RowDecoder.Columns.readAt.desc, MangaChapter.Columns.mangaId, MangaChapter.Columns.position.asc)
    }
    
    func filter(_ status: ChapterStatusHistory) -> Self {
        guard let last30days = Calendar.current.date(byAdding: .day, value: -31, to: Date()) else { return self }
        let dc = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: last30days)
        let date = DatabaseDateComponents(dc, format: .YMD_HMSS)
    
        switch status {
        case .all: return filter(RowDecoder.Columns.dateSourceUpload >= date).orderHistoryAll()
        case .read: return filter(RowDecoder.Columns.readAt >= date).orderHistoryRead().onlyRead()
        }
    }
    
    func onlyRead() -> Self {
        filter(RowDecoder.Columns.status == ChapterStatus.read)
    }
}

public extension MangaChapter {
    
    static func markAllAs(newStatus: ChapterStatus, date: Date = .now, db: Database, mangaId: UUID) throws {
        return try db.execute(sql: """
            UPDATE "mangaChapter" SET status = ?, "readAt" = ? WHERE status = ? AND "mangaId" = ?
        """, arguments: [newStatus, newStatus == .unread ? nil : date, newStatus.inverse(), mangaId])
    }
    
    static func markChapterAs(newStatus: ChapterStatus, date: Date = .now, db: Database, chapterId: String) throws {
        return try db.execute(sql: """
            UPDATE "mangaChapter" SET status = ?, "readAt" = ? WHERE status = ? AND "id" = ?
        """, arguments: [newStatus, newStatus == .unread ? nil : date, newStatus.inverse(), chapterId])
    }

    static func updateFromSource(db: Database, manga: Manga, scraper: Scraper, data: SourceManga) throws {
        // Sometimes all chapters are deleted, I don't know why and it's impossible to reproduce in test
        guard !data.chapters.isEmpty else {
            print("Empty chapters, weird so abort to avoid losing read chapters")
            return
        }
        
        let oldChapters = try MangaChapter
            .all()
            .onlyRead()
            .forMangaId(manga.mangaId, scraper.id)
            .fetchAll(db)

        for info in data.chapters.enumerated() {
            var chapter = MangaChapter(from: info.element, position: info.offset, mangaId: manga.id, scraperId: manga.scraperId!)
            if let foundBackup = oldChapters.first(where: { $0.id == chapter.id }) {
                chapter.readAt = foundBackup.readAt
                chapter.status = .read
                chapter.externalUrl = info.element.externalUrl
            }

            try chapter.save(db)
        }
        
        // Clean chapter removed from source
        let dbChapters = try MangaChapter.all().forMangaId(manga.id).fetchAll(db)
        for dbChapter in dbChapters {
            if (data.chapters.first(where: { $0.id == dbChapter.chapterId }) != nil) { continue }
            try dbChapter.delete(db)
        }
    }
}
