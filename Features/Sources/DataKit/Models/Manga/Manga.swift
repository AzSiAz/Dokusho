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
public class Manga {
    public var mangaId: String
    public var title: String
    public var cover: URL
    public var synopsis: String
    public var alternateTitles: [String]
    public var genres: [String]
    public var authors: [String]
    public var artists: [String]
    public var status: Status
    public var kind: Kind
    public var scraperId: UUID?
    
    @Relationship()
    public var collection: MangaCollection?
    
    public init(
        mangaId: String,
        title: String,
        cover: URL,
        synopsis: String,
        alternateTitles: [String],
        genres: [String],
        authors: [String],
        artists: [String],
        scraperId: UUID,
        status: Status,
        kind: Kind,
        collection: MangaCollection? = nil
    ) {
        self.mangaId = mangaId
        self.title = title
        self.cover = cover
        self.synopsis = synopsis
        self.status = status
        self.kind = kind
        self.scraperId = scraperId

        self.alternateTitles = alternateTitles
        self.genres = genres
        self.authors = authors
        self.artists = artists
        self.collection = collection
    }
    
    public init(from data: SourceManga, scraperId: UUID) {
        self.mangaId = data.id
        self.title = data.title
        self.cover = data.cover
        self.synopsis = data.synopsis
        self.alternateTitles = data.alternateNames
        self.genres = data.genres
        self.authors = data.authors
        self.artists = data.authors
        self.status = Status(rawValue: data.status)
        self.kind = Kind(rawValue: data.type)

        self.scraperId = scraperId
    }
}
