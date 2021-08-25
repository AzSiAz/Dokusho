//
//  MangaEntity.swift
//  MangaEntity
//
//  Created by Stephan Deumier on 18/08/2021.
//

import Foundation
import CoreData
import MangaSources

extension MangaEntity {
    convenience init(ctx: NSManagedObjectContext, sourceId: NSManagedObjectID, data: SourceManga) {
        self.init(entity: Self.entity(), insertInto: ctx)
        
        self.source = ctx.object(with: sourceId) as! SourceEntity?
        self.mangaId = data.id
        self.title = data.title
        self.cover = URL(string: data.cover)
        self.synopsis = data.synopsis
        self.typeRaw = data.type.rawValue
        self.statusRaw = data.status.rawValue
    }
    
    func getDefaultReadingDirection() -> ReadingDirection {
        switch self.typeRaw {
            case SourceMangaType.manga.rawValue:
                return .rightToLeft
            case SourceMangaType.manhua.rawValue:
                return .leftToRight
            case SourceMangaType.manhwa.rawValue:
                return .vertical
            case SourceMangaType.doujinshi.rawValue:
                return .rightToLeft
            default:
                return .vertical
        }
    }
}

extension MangaEntity {
    static func fetchOne(ctx: NSManagedObjectContext, mangaId: String, source: SourceEntity) -> MangaEntity? {
        let req = Self.fetchRequest()
        
        req.fetchLimit = 1
        req.predicate = Self.mangaIdAndSourcePredicate(mangaId: mangaId, source: source)
        let res = try? ctx.fetch(req)

        return res?.first
    }
}

extension MangaEntity {
    static func mangaIdAndSourcePredicate(mangaId: String, source: SourceEntity) -> NSPredicate {
        return NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(format: "%K = %@", #keyPath(MangaEntity.mangaId), mangaId),
            NSPredicate(format: "%K = %@", #keyPath(MangaEntity.source), source)
        ])
    }
    
    static func sourcePredicate(source: SourceEntity) -> NSPredicate {
        return NSPredicate(format: "%K = %@", #keyPath(MangaEntity.source), source)
    }
    
    static func updateFromSource(ctx: NSManagedObjectContext, data: SourceManga, source: SourceEntity) -> MangaEntity {
        let manga = MangaEntity.fetchOne(ctx: ctx, mangaId: data.id, source: source) ?? MangaEntity(ctx: ctx, sourceId: source.objectID, data: data)
        
        data.alternateNames
            .map { AlternateTitlesEntity(ctx: ctx, title: $0, sourceId: Int(source.sourceId)) }
            .forEach {
                ctx.insert($0)
                manga.addToAlternateTitles($0)
            }
        
        data.genres
            .map { GenreEntity(ctx: ctx, name: $0) }
            .forEach {
                ctx.insert($0)
                manga.addToGenres($0)
            }
        
        data.authors
            .map { AuthorAndArtistEntity(ctx: ctx, name: $0, type: .author) }
            .forEach {
                ctx.insert($0)
                manga.addToAuthorsAndArtists($0)
            }
        
        let oldChapters = ChapterEntity.chaptersForManga(ctx: ctx, manga: manga, source: source)
        
        let readDico: [String:Date] = oldChapters
            .filter { $0.readAt != nil }
            .reduce(into: [:]) {
                return $0[$1.chapterId!] = $1.readAt!
            }
        
        oldChapters.forEach { ctx.delete($0) }
        
        data.chapters
            .enumerated()
            .map { (index, chapter) -> ChapterEntity in
                let c = ChapterEntity(ctx: ctx, data: chapter, position: Int32(index), source: source)
                if let found = readDico[c.chapterId!] {
                    c.readAt = found
                    c.statusRaw = ChapterStatus.read.rawValue
                }
                return c
            }
            .forEach {
                ctx.insert($0)
                manga.addToChapters($0)
            }

        return manga
    }
    
    func importChapterBackup(chaptersBackup: [ChapterBackup]) {
        let chapters = self.chapters.asSet(of: ChapterEntity.self)
        
        chapters.forEach { chapter in
            guard let foundBackup = chaptersBackup.first(where: { $0.id == chapter.chapterId }) else { return }
            chapter.updateFromBackup(chapterBackup: foundBackup)
        }
    }
}
