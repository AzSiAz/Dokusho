//
//  Chapter.swift
//  Dokusho
//
//  Created by Stef on 22/12/2021.
//

import Foundation
import GRDB
import MangaScraper

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
    }
    
    static let databaseSelection: [SQLSelectable] = [
        Columns.id,
        Columns.chapterId,
        Columns.title,
        Columns.dateSourceUpload,
        Columns.position,
        Columns.readAt,
        Columns.status,
        Columns.mangaId
    ]
}

extension DerivableRequest where RowDecoder == MangaChapter {
    func forMangaId(_ mangaId: UUID) -> Self {
        filter(RowDecoder.Columns.mangaId == mangaId)
    }
    
    func forChapterStatus(_ status: ChapterStatus) -> Self {
        filter(RowDecoder.Columns.status == status)
    }
    
    func orderHistoryAll() -> Self {
        order(MangaChapter.Columns.dateSourceUpload.desc, MangaChapter.Columns.mangaId, MangaChapter.Columns.position.asc)
    }
    
    func orderHistoryRead() -> Self {
        order(MangaChapter.Columns.readAt.desc, MangaChapter.Columns.mangaId, MangaChapter.Columns.position.asc)
    }
    
    func onlyRead() -> Self {
        filter(MangaChapter.Columns.status == ChapterStatus.read)
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
}
