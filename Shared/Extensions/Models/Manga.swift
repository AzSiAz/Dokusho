//
//  Model.swift
//  Dokusho (iOS)
//
//  Created by Stephan Deumier on 21/06/2021.
//

import Foundation
import CoreData

extension SourceMangaType {
    func getDefaultReadingDirection() -> ReadingDirection {
        switch self {
            case .manga:
                return .rightToLeft
            case .manhua:
                return .leftToRight
            case .manhwa:
                return .vertical
            case .doujinshi:
                return .rightToLeft
            case .unknown:
                return .vertical
        }
    }
}

extension Manga {
    var unique: String { "\(self.source)@@\(self.id!)" }
    
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
    
    static func fetchOne(mangaId: String, sourceId: Int16, ctx: NSManagedObjectContext) -> Manga? {
        let req = Manga.fetchRequest()
        req.fetchLimit = 1
        req.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(format: "id = %@", mangaId),
            NSPredicate(format: "source = %i", sourceId)
        ])
        let res = try? ctx.fetch(req)
        
        return res?.first
    }
    
    static func fromSource(for m: SourceManga, source: Source, context ctx: NSManagedObjectContext) -> Manga {
        let maybeHere = Manga.fetchOne(mangaId: m.id, sourceId: source.id, ctx: ctx)
        
        guard let found = maybeHere else {
            return Manga(context: ctx).updateFromSource(for: m, source: source, context: ctx)
        }

        return found.updateFromSource(for: m, source: source, context: ctx)
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
    
    func nextUnreadChapter() -> MangaChapter? {
        guard let chapters = self.chapters as? Set<MangaChapter> else { return nil }
        
        let sort = SortDescriptor(\MangaChapter.position, order: .reverse)
        
        return chapters.sorted(using: sort).first { $0.status == .unread }
    }
}
