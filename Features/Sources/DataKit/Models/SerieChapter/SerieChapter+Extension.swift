import Foundation
import GRDB

public extension SerieChapter {
    typealias InternalID = String

    enum CodingKeys: String, CodingKey {
        case id, internalID, title, subTitle, uploadedAt, volume, chapter, readAt, progress, externalUrl, serieID
    }
}

extension SerieChapter: FetchableRecord, PersistableRecord {}

extension SerieChapter: TableRecord {
    public static var databaseTableName: String = "serieChapter"
    
    public static let serie = belongsTo(Serie.self)
    public static let scraper = hasOne(Scraper.self, through: serie, using: Serie.scraper)
    
    public enum Columns {
        public static let id = Column(CodingKeys.id)
        public static let internalID = Column(CodingKeys.internalID)
        public static let title = Column(CodingKeys.title)
        public static let subTitle = Column(CodingKeys.subTitle)
        public static let uploadedAt = Column(CodingKeys.uploadedAt)
        public static let volume = Column(CodingKeys.volume)
        public static let chapter = Column(CodingKeys.chapter)
        public static let readAt = Column(CodingKeys.readAt)
        public static let progress = Column(CodingKeys.progress)
        public static let externalUrl = Column(CodingKeys.externalUrl)
        public static let serieID = Column(CodingKeys.serieID)
    }
    
    public static let databaseSelection: [SQLSelectable] = [
        Columns.id,
        Columns.internalID,
        Columns.title,
        Columns.subTitle,
        Columns.uploadedAt,
        Columns.volume,
        Columns.chapter,
        Columns.readAt,
        Columns.progress,
        Columns.externalUrl,
        Columns.serieID
    ]
}

public extension DerivableRequest<SerieChapter> {
    func whereSerie(serieID: Serie.ID) -> Self {
        filter(RowDecoder.Columns.serieID == serieID)
    }
    
    func orderByPosition(asc: Bool) -> Self {
        if asc {
            return order(RowDecoder.Columns.volume.asc, RowDecoder.Columns.chapter.asc)
        } else {
            return order(RowDecoder.Columns.volume.desc, RowDecoder.Columns.chapter.desc)
        }
    }
    
    func onlyRead() -> Self {
        filter(RowDecoder.Columns.readAt != nil)
    }
    
    func onlyUnRead() -> Self {
        filter(RowDecoder.Columns.readAt == nil)
    }
    
    func orderHistoryAll() -> Self {
        order(RowDecoder.Columns.uploadedAt.desc, RowDecoder.Columns.internalID, RowDecoder.Columns.volume.desc, RowDecoder.Columns.chapter.desc)
    }
    
    func orderHistoryRead() -> Self {
        order(RowDecoder.Columns.readAt.desc, RowDecoder.Columns.internalID, RowDecoder.Columns.volume.desc, RowDecoder.Columns.chapter.desc)
    }
}
