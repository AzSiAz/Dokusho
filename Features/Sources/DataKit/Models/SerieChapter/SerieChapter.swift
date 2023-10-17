import Foundation
import SwiftData
import SerieScraper

@Model
public class SerieChapter {
    public var internalId: String?
    public var title: String?
    public var subTitle: String?
    public var uploadedAt: Date?
    public var volume: Float?
    public var chapter: Float?
    public var readAt: Date?
    public var progress: Int?
    public var externalUrl: URL?
    
    @Relationship()
    public var serie: Serie?
    
    public init(from data: SourceChapter, serie: Serie? = nil) {
        self.internalId = data.id
        self.title = data.name
        self.subTitle = data.subTitle
        self.uploadedAt = data.dateUpload
        self.chapter = data.chapter
        self.volume = data.volume
        self.externalUrl = data.externalUrl
        self.progress = nil
        
        self.serie = serie
    }
    
    public func update(from data: SourceChapter) {
        if (self.title != data.name) { self.title = data.name }
        if (self.subTitle != data.subTitle) { self.title = data.subTitle }
        if (self.uploadedAt != data.dateUpload) { self.uploadedAt = data.dateUpload }
        if (self.chapter != data.chapter) { self.chapter = data.chapter }
        if (self.volume != data.volume) { self.volume = data.volume }
        if (self.externalUrl != data.externalUrl) { self.externalUrl = data.externalUrl }
    }
}
