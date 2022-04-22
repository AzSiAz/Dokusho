//
//  Chapter.swift
//  Dokusho
//
//  Created by Stef on 22/12/2021.
//

import Foundation
import GRDB
import MangaScraper

enum ChapterStatusFilter: String {
    case all
    case unread
    
    static func toggle(value: Self) -> Self {
        if value == .all {
            return .unread
        }
        else {
            return .all
        }
    }
    
}

enum ChapterStatus: String, CaseIterable, Codable, DatabaseValueConvertible {
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

struct MangaChapter: Identifiable, Equatable, Codable {
    var id: String
    var chapterId: String
    var title: String
    var dateSourceUpload: Date
    var position: Int
    var readAt: Date?
    var status: ChapterStatus
    var mangaId: UUID
    var externalUrl: String?
    
    var isUnread: Bool {
        return status != .read
    }
    
    init(from data: SourceChapter, position: Int, mangaId: UUID, scraperId: UUID) {
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
    static let manga = belongsTo(Manga.self)
    static let scraper = hasOne(Scraper.self, through: manga, using: Manga.scraper)

    enum Columns {
        static let id = Column(CodingKeys.id)
        static let chapterId = Column(CodingKeys.chapterId)
        static let title = Column(CodingKeys.title)
        static let dateSourceUpload = Column(CodingKeys.dateSourceUpload)
        static let position = Column(CodingKeys.position)
        static let readAt = Column(CodingKeys.readAt)
        static let status = Column(CodingKeys.status)
        static let mangaId = Column(CodingKeys.mangaId)
        static let externalUrl = Column(CodingKeys.externalUrl)
    }
    
    static let databaseSelection: [SQLSelectable] = [
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

extension DerivableRequest where RowDecoder == MangaChapter {
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

extension MangaChapter {
    
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
            if let foundBackup = oldChapters.first(where: { $0.id == chapter.chapterId }) {
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
