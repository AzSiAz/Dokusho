//
//  MangaEntity.swift
//  MangaEntity
//
//  Created by Stephan Deumier on 18/08/2021.
//

import Foundation
import CoreData
import MangaScraper

extension MangaEntity {
    convenience init(ctx: NSManagedObjectContext, sourceId: NSManagedObjectID, data: SourceManga) throws {
        self.init(entity: Self.entity(), insertInto: ctx)
        
        guard let source = ctx.object(with: sourceId) as? SourceEntity else { throw "Source \(sourceId) not found" }
        self.source = source
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
    static func fetchOne(ctx: NSManagedObjectContext, mangaId: String, source: SourceEntity, includeChapters: Bool = false) -> MangaEntity? {
        let req = Self.fetchRequest()
        
        req.fetchLimit = 1
        req.predicate = Self.mangaIdAndSourcePredicate(mangaId: mangaId, source: source)
        
        return try? ctx.fetch(req).first
    }
}

extension MangaEntity {
    static func updateFromSource(ctx taskCtx: NSManagedObjectContext, data: SourceManga, source: SourceEntity) throws -> MangaEntity {
        let manga: MangaEntity
        if let found = MangaEntity.fetchOne(ctx: taskCtx, mangaId: data.id, source: source) {
            manga = found
        } else {
            manga = try MangaEntity(ctx: taskCtx, sourceId: source.objectID, data: data)
        }
        
        data.alternateNames
            .map { AlternateTitlesEntity(ctx: taskCtx, title: $0, sourceId: Int(source.sourceId)) }
            .forEach {
                taskCtx.insert($0)
                manga.addToAlternateTitles($0)
            }
        
        data.genres
            .map { GenreEntity(ctx: taskCtx, name: $0) }
            .forEach {
                taskCtx.insert($0)
                manga.addToGenres($0)
            }
        
        data.authors
            .map { AuthorAndArtistEntity(ctx: taskCtx, name: $0, type: .author) }
            .forEach {
                taskCtx.insert($0)
                manga.addToAuthorsAndArtists($0)
            }
        
        let oldChapters = ChapterEntity.chaptersForManga(ctx: taskCtx, manga: manga.objectID, source: source.objectID)
        
        let readDico: [String:Date] = oldChapters
            .filter { $0.readAt != nil }
            .reduce(into: [:]) {
                return $0[$1.chapterId!] = $1.readAt!
            }
        
        oldChapters.forEach { taskCtx.delete($0) }
        
        data.chapters
            .enumerated()
            .map { (index, chapter) -> ChapterEntity in
                let c = ChapterEntity(ctx: taskCtx, data: chapter, position: Int32(index), source: source)
                c.markAs(newStatus: .unread)

                if let found = readDico[c.chapterId!] {
                    c.markAs(newStatus: .read, date: found)
                }
                
                return c
            }
            .forEach {
                taskCtx.insert($0)
                manga.addToChapters($0)
            }
        
        manga.lastChapterUploadDate = manga
            .chapters?
            .first(where: { $0.position == 0 })?
            .dateSourceUpload

        return manga
    }
    
    func importChapterBackup(chaptersBackup: [ChapterBackup]) {
        guard let chapters = self.chapters else { return }

        chapters.forEach { chapter in
            guard let foundBackup = chaptersBackup.first(where: { $0.id == chapter.chapterId }) else { return }
            chapter.updateFromBackup(chapterBackup: foundBackup)
        }
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
    
    static func collectionPredicate(collection: CollectionEntity) -> NSPredicate {
        var predicate = [NSPredicate(format: "%K = %@", #keyPath(MangaEntity.collection), collection)]

        switch collection.filter {
            case .all: break
            case .read:
                predicate.append(NSPredicate(format: "SUBQUERY(%K, $chapter, $chapter.%K = %@).@count == 0", #keyPath(MangaEntity.chapters), #keyPath(ChapterEntity.statusRaw), ChapterStatus.unread.rawValue))
            case .unread:
                predicate.append(NSPredicate(format: "ANY %K.%K = %@", #keyPath(MangaEntity.chapters), #keyPath(ChapterEntity.statusRaw), ChapterStatus.unread.rawValue))
        }
        
        return NSCompoundPredicate(andPredicateWithSubpredicates: predicate)
    }
    
    static func inCollectionForSource(source: SourceEntity) -> NSPredicate {
        return NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(format: "%K != nil", #keyPath(MangaEntity.collection)),
            Self.sourcePredicate(source: source)
        ])
    }
    
    static var nameOrder: SortDescriptor<MangaEntity> {
        return SortDescriptor<MangaEntity>(\.title, order: .forward)
    }
    
    static var lastUpdate: SortDescriptor<MangaEntity> {
        return SortDescriptor<MangaEntity>(\.lastChapterUploadDate, order: .reverse)
    }

}
