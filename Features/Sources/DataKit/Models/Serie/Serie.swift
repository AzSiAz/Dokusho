import Foundation
import SerieScraper
import SwiftData

@Model
public class Serie: Identifiable, Equatable, Hashable {
    public var id: UUID
    public var internalID: InternalID
    public var title: String
    public var cover: URL
    public var synopsis: String
    public var alternateTitles: [String]
    public var genres: [String]
    public var authors: [String]
    public var status: Status
    public var kind: Kind
    public var readerDirection: ReaderDirection
    
    public var scraperID: UUID
    public var collection: SerieCollection?
    
    @Relationship()
    public var chapters: [SerieChapter]
    
    public init(
        id: Serie.ID,
        internalID: InternalID,
        title: String,
        cover: URL,
        synopsis: String,
        alternateTitles: [String],
        genres: [String],
        authors: [String],
        status: Status,
        kind: Kind,
        readerDirection: ReaderDirection,
        scraperID: UUID,
        collection: SerieCollection,
        chapters: [SerieChapter]? = nil
    ) {
        self.id = id
        self.internalID = internalID
        self.title = title
        self.cover = cover
        self.synopsis = synopsis
        self.alternateTitles = alternateTitles
        self.genres = genres
        self.authors = authors
        self.status = status
        self.kind = kind
        self.readerDirection = readerDirection
        
        self.scraperID = scraperID
        self.collection = collection
        self.chapters = chapters ?? []
    }

    public init(from data: SourceSerie, scraperID: UUID, collection: SerieCollection? = nil) {
        self.id = UUID()
        self.internalID = data.id
        self.title = data.title
        self.cover = data.cover
        self.synopsis = data.synopsis
        self.alternateTitles = data.alternateTitles
        self.genres = data.genres
        self.authors = data.authors
        self.status = Status(data.status)
        self.kind = Kind(data.type)
        self.readerDirection = ReaderDirection(data.type)

        self.scraperID = scraperID
        self.collection = collection
        self.chapters = []
    }
    
    public func update(from data: SourceSerie) {
        if (self.title != data.title) { self.title = data.title }
        if (self.cover != data.cover) { self.cover = data.cover }
        if (self.synopsis != data.synopsis) { self.synopsis = data.synopsis }
        if (self.alternateTitles != data.alternateTitles) { self.alternateTitles = data.alternateTitles }
        if (self.status != Status(data.status)) { self.status = Status(data.status) }
        if (self.kind != Kind(data.type)) { self.kind = Kind(data.type) }
    }
    
    public func changeCollection(serieCollection: SerieCollection) {
        self.collection = serieCollection
    }
}
