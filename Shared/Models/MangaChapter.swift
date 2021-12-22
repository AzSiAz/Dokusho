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
    var title: String
    var dateSourceUpload: Date
    var position: Int
    var readAt: Date?
    var status: ChapterStatus
    var mangaId: UUID
    
    static func markAllAs(newStatus: ChapterStatus, date: Date = .now, db: Database, mangaId: UUID) throws {
        return try db.execute(sql: """
            UPDATE "mangaChapter" SET status = ?, "readAt" = ? WHERE status = ? AND "mangaId" = ?
        """, arguments: [newStatus, date, newStatus.inverse(), mangaId])
    }
    
    init(from data: SourceChapter, position: Int, mangaId: UUID) {
        self.id = data.id
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

    enum Columns {
        static let id = Column(CodingKeys.id)
        static let title = Column(CodingKeys.title)
        static let dateSourceUpload = Column(CodingKeys.dateSourceUpload)
        static let position = Column(CodingKeys.position)
        static let readAt = Column(CodingKeys.readAt)
        static let status = Column(CodingKeys.status)
        static let mangaId = Column(CodingKeys.mangaId)
    }
    
    static let databaseSelection: [SQLSelectable] = [
        Columns.id,
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
}

