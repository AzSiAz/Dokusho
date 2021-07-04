//
//  Manga.swift
//  Dokusho (iOS)
//
//  Created by Stephan Deumier on 28/06/2021.
//

import Foundation
import CoreData

@objc(Manga)
class Manga: NSManagedObject, Identifiable {
    @NSManaged var cover: String?
    @NSManaged var desc: String?
    @NSManaged var id: String?
    @NSManaged var lastChapterUpdate: Date?
    @NSManaged var source: Int16
    @NSManaged var statusRaw: String?
    @NSManaged var title: String?
    @NSManaged var typeRaw: String?
    
    @NSManaged var alternateNames: Set<MangaAlternatesName>?
    @NSManaged var authors: Set<MangaAuthor>?
    @NSManaged var chapters: Set<MangaChapter>?
    @NSManaged var collection: MangaCollection?
    @NSManaged var genres: Set<MangaGenre>?
    
    static func fetchRequest() -> NSFetchRequest<Manga> {
        return NSFetchRequest<Manga>(entityName: "Manga")
    }
}

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
    
    static func createFromSource(for m: SourceManga, source: Source, context ctx: NSManagedObjectContext) -> Manga {
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
        
        self.addFromRawGenres(names: m.genres, context: ctx)
        self.addFromRawAuthors(names: m.authors, context: ctx)
        self.addFromRawAlternatesNames(alternateNames: m.alternateNames, context: ctx)
        self.addToChapters(chapters: m.chapters, context: ctx)
        
        let firstChapter: MangaChapter? = self.chapters?.first { $0.position == 0 }
        
        self.lastChapterUpdate = firstChapter?.dateSourceUpload
        
        return self
    }
    
    func addFromRawGenres(names: [String], context ctx: NSManagedObjectContext) {
        MangaGenre.createFromSource(manga: self, names: names, context: ctx)
    }
    
    func addToGenres(_ genre: MangaGenre) {
        guard self.genres?.contains(where: { $0.name == genre.name }) == false else { return }

        self.genres?.insert(genre)
    }
    
    func addFromRawAuthors(names: [String], context ctx: NSManagedObjectContext) {
        MangaAuthor.createFromSource(manga: self, names: names, context: ctx)
    }
    
    func addToAuthors(_ author: MangaAuthor) {
        guard self.authors?.contains(where: { $0.name == author.name }) == false else { return }

        self.authors?.insert(author)
    }
    
    func addToChapters(chapters: [SourceChapter], context ctx: NSManagedObjectContext) {
        MangaChapter.createFromSource(manga: self, chapters: chapters, context: ctx)
    }
    
    func addToChapters(_ chapter: MangaChapter) {
        guard self.chapters?.contains(chapter) == false else { return }

        self.chapters?.insert(chapter)
    }
    
    func addFromRawAlternatesNames(alternateNames: [String], context ctx: NSManagedObjectContext) {
        MangaAlternatesName.createFromSource(manga: self, titles: alternateNames, context: ctx)
    }
    
    func addToAlternatesNames(_ alternateName: MangaAlternatesName) {
        guard self.alternateNames?.contains(where: { $0.title == alternateName.title }) == false else { return }
        
        self.alternateNames?.insert(alternateName)
    }
    
    func unreadChapterCount() -> Int {
        guard let chapters = self.chapters else { return 0 }

        return chapters.filter { $0.status == .unread }.count
    }
    
    func nextUnreadChapter() -> MangaChapter? {
        guard let chapters = self.chapters else { return nil }
        
        let sort = SortDescriptor(\MangaChapter.position, order: .reverse)
        return chapters.sorted(using: sort).first { $0.status == .unread }
    }
}

extension Manga {
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
    
    static func mangaOneFetch(mangaId: String, srcId: Int16) -> NSFetchRequest<Manga> {
        let req = Manga.fetchRequest()
        req.fetchLimit = 1
        req.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(format: "id = %@", mangaId),
            NSPredicate(format: "source = %i", srcId)
        ])
        req.sortDescriptors = []
        
        return req
    }
    
    static func fetchMany(collection: MangaCollection) -> NSFetchRequest<Manga> {
        let req = Self.fetchRequest()
        
        req.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(format: "collection = %@", collection),
        ])
        
        req.sortDescriptors = [
            NSSortDescriptor(keyPath: \Manga.lastChapterUpdate, ascending: false)
        ]
        
        return req
    }
}
