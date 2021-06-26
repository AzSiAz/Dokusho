//
//  Model.swift
//  Dokusho (iOS)
//
//  Created by Stephan Deumier on 21/06/2021.
//

import Foundation
import CoreData

extension Manga {
    var type: SourceMangaType {
        get {
            return .init(rawValue: self.typeRaw ?? "") ?? .unknown
        }
        
        set {
            self.typeRaw = newValue.rawValue
        }
    }
    
    var status: SourceMangaCompletion {
        get {
            return .init(rawValue: self.statusRaw ?? "") ?? .unknown
        }
        
        set {
            self.statusRaw = newValue.rawValue
        }
    }
    
    static func fromSource(for m: SourceManga, source: Source, context ctx: NSManagedObjectContext) -> Manga {
        let manga = Manga(context: ctx)
        
        manga.source = source.id
        manga.id = m.id
        manga.title = m.title
        manga.cover = m.thumbnailUrl
        manga.desc = m.description
        
        manga.type = m.type
        manga.status = m.status

        manga.addToGenres(genres: m.genres, context: ctx)
        manga.addToAuthors(authors: m.authors, context: ctx)
        manga.addToAlternateNames(alternateNames: m.alternateNames, context: ctx)
        manga.addToChapters(chapters: m.chapters, mangaId: m.id, context: ctx)

        return manga
    }
    
    func addToGenres(genres: [String], context ctx: NSManagedObjectContext) {
        self.addToGenres(NSSet(array: MangaGenre.fromSource(genres: genres, context: ctx)))
    }
    
    func addToAuthors(authors: [String], context ctx: NSManagedObjectContext) {
        self.addToAuthors(NSSet(array: MangaAuthor.fromSource(authors: authors, context: ctx)))
    }
    
    func addToChapters(chapters: [SourceChapter], mangaId: String, context ctx: NSManagedObjectContext) {
        self.chapters = NSSet(array: MangaChapter.fromSource(chapters: chapters, mangaId: mangaId, context: ctx))
    }
    
    func addToAlternateNames(alternateNames: [String], context ctx: NSManagedObjectContext) {
        self.addToAlternateNames(
            NSSet(array: MangaAlternatesName.fromSource(titles: alternateNames, context: ctx))
        )
    }
}
