//
//  MangaEntity.swift
//  MangaEntity
//
//  Created by Stephan Deumier on 18/08/2021.
//

import Foundation
import CoreData
import MangaScraper

enum ReadingDirection: String, CaseIterable {
    case rightToLeft = "Right to Left (Manga)"
    case leftToRight = "Left to Right (Manhua)"
    case vertical = "Vertical (Webtoon, no gaps)"
}

extension MangaEntity {
    func getSource() -> Source {
        return MangaScraperService.shared.getSource(sourceId: self.sourceId)!
    }
}

extension MangaEntity {
    convenience init(ctx: NSManagedObjectContext, sourceId: UUID, data: SourceManga) throws {
        self.init(entity: Self.entity(), insertInto: ctx)

        self.sourceId = sourceId
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
    static func fetchOne(ctx: NSManagedObjectContext, mangaId: String, sourceId: UUID, includeChapters: Bool = false) -> MangaEntity? {
        let req = Self.fetchRequest()
        
        req.fetchLimit = 1
        req.predicate = Self.mangaIdAndSourcePredicate(mangaId: mangaId, sourceId: sourceId)
        
        return try? ctx.fetch(req).first
    }
    
    static func fetchLatestUpdate(ctx: NSManagedObjectContext, collectionUUID: String, limit: Int = 6) -> [MangaEntity] {
        let req = Self.fetchRequest()
        
        req.fetchLimit = limit
        req.predicate = NSPredicate(format: "%K = %@", #keyPath(MangaEntity.collection.uuid), collectionUUID)
        req.sortDescriptors = [NSSortDescriptor(MangaEntity.lastUpdate)]
        
        return (try? ctx.fetch(req)) ?? []
    }
}

extension MangaEntity {
    static func updateFromSource(ctx taskCtx: NSManagedObjectContext, data: SourceManga, source: Source) throws -> MangaEntity {
        let manga: MangaEntity
        if let found = MangaEntity.fetchOne(ctx: taskCtx, mangaId: data.id, sourceId: source.id) {
            manga = found
        } else {
            manga = try MangaEntity(ctx: taskCtx, sourceId: source.id, data: data)
        }
        
        manga.title = data.title
        manga.synopsis = data.synopsis
        manga.cover = URL(string: data.cover)
        manga.statusRaw = data.status.rawValue
        manga.typeRaw = data.type.rawValue
        
        if manga.alternateTitles?.count ?? 0 > 0 {
            manga.alternateTitles!.forEach { taskCtx.delete($0) }
        }
        
        data.alternateNames
            .map { AlternateTitlesEntity.fromSourceSource(ctx: taskCtx, title: $0, sourceId: source.id, manga: manga) }
            .forEach { taskCtx.insert($0) }
        
        if manga.genres?.count ?? 0 > 0 {
            manga.genres!.forEach { $0.removeFromMangas(manga) }
        }
        
        data.genres
            .map { GenreEntity.fromSourceSource(ctx: taskCtx, name: $0, manga: manga) }
            .forEach { taskCtx.insert($0) }
        
        if manga.authorsAndArtists?.count ?? 0 > 0 {
            manga.authorsAndArtists!.forEach { $0.removeFromMangas(manga) }
        }
        
        data.authors
            .map { AuthorAndArtistEntity.fromSourceSource(ctx: taskCtx, name: $0, type: .author, manga: manga) }
            .forEach { taskCtx.insert($0) }
        
        let oldChapters = ChapterEntity.chaptersForManga(ctx: taskCtx, manga: manga.objectID)
        
        let readDico: [String:Date] = oldChapters
            .filter { $0.readAt != nil }
            .reduce(into: [:]) { return $0[$1.chapterId!] = $1.readAt! }
        
        oldChapters.forEach { taskCtx.delete($0) }
        
        data.chapters
            .enumerated()
            .map { (index, chapter) -> ChapterEntity in
                let c = ChapterEntity(ctx: taskCtx, data: chapter, position: Int32(index), sourceId: source.id)
                c.markAs(newStatus: .unread)

                if let found = readDico[c.chapterId!] { c.markAs(newStatus: .read, date: found) }
                
                return c
            }
            .forEach {
                if $0.position == 0 { manga.lastChapterUploadDate = $0.dateSourceUpload }
                
                taskCtx.insert($0)
                manga.addToChapters($0)
            }

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
    static func mangaIdAndSourcePredicate(mangaId: String, sourceId: UUID) -> NSPredicate {
        return NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(format: "%K = %@", #keyPath(MangaEntity.mangaId), mangaId),
            sourcePredicate(sourceId: sourceId)
        ])
    }
    
    static func sourcePredicate(sourceId: UUID) -> NSPredicate {
        return NSPredicate(format: "%K = %@", #keyPath(MangaEntity.sourceId), sourceId as NSUUID)
    }
    
    static func collectionPredicate(collection: CollectionEntity, searchTerm: String = "") -> NSPredicate {
        var predicate = [NSPredicate(format: "%K = %@", #keyPath(MangaEntity.collection), collection)]
        
        if !searchTerm.isEmpty {
            predicate.append(NSCompoundPredicate(orPredicateWithSubpredicates: [
                NSPredicate(format: "%K CONTAINS[cd] %@", #keyPath(MangaEntity.title), searchTerm),
                NSPredicate(format: "%K CONTAINS[cd] %@", #keyPath(MangaEntity.alternateTitles.title), searchTerm)
            ]))
        }

        switch collection.filter {
            case .all: break
            case .read:
                predicate.append(NSPredicate(format: "SUBQUERY(%K, $chapter, $chapter.%K = %@).@count == 0", #keyPath(MangaEntity.chapters), #keyPath(ChapterEntity.statusRaw), ChapterStatus.unread.rawValue))
            case .unread:
                predicate.append(NSPredicate(format: "ANY %K.%K = %@", #keyPath(MangaEntity.chapters), #keyPath(ChapterEntity.statusRaw), ChapterStatus.unread.rawValue))
        }
        
        return NSCompoundPredicate(andPredicateWithSubpredicates: predicate)
    }
    
    static func inCollectionForSource(sourceId: UUID) -> NSPredicate {
        return NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(format: "%K != nil", #keyPath(MangaEntity.collection)),
            Self.sourcePredicate(sourceId: sourceId)
        ])
    }
    
    static var nameOrder: SortDescriptor<MangaEntity> {
        return SortDescriptor<MangaEntity>(\.title, order: .forward)
    }
    
    static var lastUpdate: SortDescriptor<MangaEntity> {
        return SortDescriptor<MangaEntity>(\.lastChapterUploadDate, order: .reverse)
    }

    static func forGenres(genre: GenreEntity) -> NSPredicate {
        return NSPredicate(format: "ANY %K.%K = %@", #keyPath(MangaEntity.genres), #keyPath(GenreEntity.name), genre.name!)
    }
}
