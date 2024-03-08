import Foundation
import GRDB
import SerieScraper

public struct SerieChapter: Identifiable, Equatable, Codable, Hashable {
    public var id: UUID
    public var internalID: InternalID
    public var title: String
    public var subTitle: String?
    public var uploadedAt: Date
    public var volume: Float?
    public var chapter: Float
    public var readAt: Date?
    public var progress: Int?
    public var externalUrl: URL?

    public var serieID: UUID
    
    public var archivedRecordData: Data?

    public init(from data: SourceChapter, serieID: UUID) {
        self.id = UUID()
        self.internalID = data.id
        self.title = data.name
        self.subTitle = data.subTitle
        self.uploadedAt = data.dateUpload
        self.chapter = data.chapter
        self.volume = data.volume
        self.externalUrl = data.externalUrl
        self.progress = nil

        self.serieID = serieID
    }

    public mutating func update(from data: SourceChapter) {
        if (self.title != data.name) { self.title = data.name }
        if (self.subTitle != data.subTitle) { self.subTitle = data.subTitle }
        if (self.uploadedAt != data.dateUpload) { self.uploadedAt = data.dateUpload }
        if (self.chapter != data.chapter) { self.chapter = data.chapter }
        if (self.volume != data.volume) { self.volume = data.volume }
        if (self.externalUrl != data.externalUrl) { self.externalUrl = data.externalUrl }
    }
    
    public mutating func toggleReadAt() {
        if self.readAt == nil {
            self.readAt = .now
        } else {
            self.readAt = nil
        }
    }
    
    public mutating func setReadAt(date: Date?) {
        self.readAt = date
    }
}
