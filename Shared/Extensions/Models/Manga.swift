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

        return manga.updateFromSource(for: m, source: source, context: ctx)
    }
    
    func updateFromSource(for m: SourceManga, source: Source, context ctx: NSManagedObjectContext) -> Self {
        self.id = m.id
        self.source = source.id
        self.title = m.title
        self.cover = m.thumbnailUrl
        self.desc = m.description
        
        self.type = m.type
        self.status = m.status
        
        self.addToGenres(genres: m.genres, context: ctx)
        self.addToAuthors(authors: m.authors, context: ctx)
        self.addToAlternateNames(alternateNames: m.alternateNames, context: ctx)
        self.addToChapters(chapters: m.chapters, context: ctx)
        
        let firstChapter: MangaChapter? = (self.chapters?.allObjects as? [MangaChapter])?.first { $0.position == 0 }
        
        self.lastChapterUpdate = firstChapter?.dateSourceUpload
        
        return self
    }
    
    func addToGenres(genres: [String], context ctx: NSManagedObjectContext) {
        self.addToGenres(NSSet(array: MangaGenre.fromSource(genres: genres, context: ctx)))
    }
    
    func addToAuthors(authors: [String], context ctx: NSManagedObjectContext) {
        self.addToAuthors(NSSet(array: MangaAuthor.fromSource(authors: authors, context: ctx)))
    }
    
    func addToChapters(chapters: [SourceChapter], context ctx: NSManagedObjectContext) {
        MangaChapter.fromSource(chapters: chapters, manga: self, context: ctx)
    }
    
    func addToAlternateNames(alternateNames: [String], context ctx: NSManagedObjectContext) {
        self.addToAlternateNames(
            NSSet(array: MangaAlternatesName.fromSource(titles: alternateNames, context: ctx))
        )
    }
    
    func unreadChapterCount() -> Int {
        guard let chapters = self.chapters as? Set<MangaChapter> else { return 0 }
        return chapters.filter { $0.status.isUnread() }.count
    }
}
