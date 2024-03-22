//
//  File.swift
//  
//
//  Created by Stephan Deumier on 22/03/2024.
//

import Foundation
import SerieScraper

public extension Serie {
    init(backup: Backup.V2) {
        self.id = backup.id
        self.internalID = backup.internalID
        self.title = backup.title
        self.cover = backup.cover
        self.synopsis = backup.synopsis
        self.alternateTitles = backup.alternateTitles
        self.genres = backup.genres
        self.authors = backup.authors
        self.status = backup.status
        self.kind = backup.kind
        self.readerDirection = backup.readerDirection
        
        self.scraperID = backup.scraperID
        self.collectionID = backup.collectionID
    }
    
    init(backup: Backup.V1, scraperID: Scraper.ID, serieCollectionID: SerieCollection.ID) {
        self.id = backup.id
        self.internalID = backup.mangaId
        self.title = backup.title
        self.cover = backup.cover
        self.synopsis = backup.synopsis
        self.alternateTitles = backup.alternateTitles
        self.genres = backup.genres
        self.authors = backup.authors
        self.status = .init(backup.status)
        self.kind = .init(backup.type)
        self.readerDirection = .init(backup.type)

        self.scraperID = scraperID
        self.collectionID = serieCollectionID
    }
    
    struct Backup {
        public struct V1: Codable {
            public var id: UUID
            public var mangaId: String
            public var title: String
            public var cover: URL
            public var synopsis: String
            public var alternateTitles: [String]
            public var genres: [String]
            public var authors: [String]
            public var artists: [String]
            public var status: SourceSerieCompletion
            public var type: SourceSerieType
            public var scraperId: UUID?
            public var mangaCollectionId: UUID?
        }
        
        public typealias V2 = Serie
    }
}
