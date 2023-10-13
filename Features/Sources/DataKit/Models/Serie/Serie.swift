//
//  File.swift
//  
//
//  Created by Stephan Deumier on 07/10/2023.
//

import Foundation
import SwiftData
import MangaScraper

@Model
public class Serie {
    public var mangaId: String?
    public var title: String?
    public var cover: URL?
    public var synopsis: String?
    public var alternateTitles: [String]?
    public var genres: [String]?
    public var authors: [String]?
    public var status: Status?
    public var kind: Kind?
    public var scraperId: UUID?
    public var readerDirection: ReaderDirection?

    @Relationship()
    public var collection: SerieCollection?

    @Relationship(deleteRule: .cascade, inverse: \Chapter.serie)
    public var chapters: [Chapter]?

    public init(from data: SourceManga, scraperId: UUID, collection: SerieCollection? = nil, chapters: [Chapter] = []) {
        self.mangaId = data.id
        self.title = data.title
        self.cover = data.cover
        self.synopsis = data.synopsis
        self.alternateTitles = data.alternateTitles
        self.genres = data.genres
        self.authors = data.authors
        self.status = Status(rawValue: data.status)
        self.kind = Kind(rawValue: data.type)
        self.readerDirection = ReaderDirection(from: data.type)

        self.scraperId = scraperId
        
        self.chapters = chapters
        self.collection = collection
    }
    
    public func update(from data: SourceManga) {
        if (self.title != data.title) { self.title = data.title }
        if (self.cover != data.cover) { self.cover = data.cover }
        if (self.synopsis != data.synopsis) { self.synopsis = data.synopsis }
        if (self.alternateTitles != data.alternateTitles) { self.alternateTitles = data.alternateTitles }
        if (self.status != Status(rawValue: data.status)) { self.status = Status(rawValue: data.status) }
        if (self.kind != Kind(rawValue: data.type)) { self.kind = Kind(rawValue: data.type) }
    }
}
