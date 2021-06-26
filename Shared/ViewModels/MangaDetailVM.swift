//
//  MangaDetailVM.swift
//  Dokusho (iOS)
//
//  Created by Stephan Deumier on 14/06/2021.
//

import Foundation
import CoreData

@MainActor
class MangaDetailVM: ObservableObject {
    enum ChapterOrder {
        case base
        case reversed
        
        mutating func toggle() {
            if self == .reversed {
                self = .base
            }
            else {
                self = .reversed
            }
        }
    }
    
    enum ChapterFilter {
        case all
        case unread
        
        mutating func toggle() {
            if self == .all {
                self = .unread
            }
            else {
                self = .all
            }
        }
    }
    
    let src: Source
    let mangaId: String
    var ctx: NSManagedObjectContext

    @Published var error = false
    @Published var manga: Manga?
    @Published var selectedChapter: MangaChapter?
    @Published var chapterOrder: ChapterOrder = .base
    @Published var chapterFilter: ChapterFilter = .all
    @Published var libState: LibraryState
    
    init(for source: Source, mangaId: String, context ctx: NSManagedObjectContext, libState: LibraryState) {
        self.src = source
        self.mangaId = mangaId
        self.ctx = ctx
        self.libState = libState
    }
    
    func fetchManga() async {
        self.error = false

        do {
            let req = Manga.fetchRequest()
            req.fetchLimit = 1
            req.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
                NSPredicate(format: "id = %@", mangaId),
                NSPredicate(format: "source = %i", src.id)
            ])
            let res = try ctx.fetch(req)

            if res.isEmpty { await fetchAndInsert() }
            else { manga = res.first }
        } catch {
            self.error = true
        }
    }
    
    func fetchAndInsert() async {
        self.error = false
        self.manga = nil
        
        do {
            let sourceManga = try await src.fetchMangaDetail(id: mangaId)
            self.manga = Manga.fromSource(for: sourceManga, source: src, context: ctx)
            try ctx.save()
        } catch {
            self.error = true
        }
    }
    
    func refresh() async {
        self.error = false

        do {
            let sourceManga = try await src.fetchMangaDetail(id: mangaId)
            self.manga = self.manga?.updateFromSource(for: sourceManga, source: src, context: ctx)
            try ctx.save()
            libState.reloadCollection()
        } catch {
            self.error = true
        }
    }
    
    func chapters() -> [MangaChapter] {
        guard manga != nil else { return [] }
        guard manga!.chapters?.count != 0 else { return [] }
        
        guard let chapters = manga?.chapters as? Set<MangaChapter> else { return [] }
        
        let filteredChapters = chapters.filter { self.chapterFilter == .all ? true : $0.status.isUnread() }
        let orderedChapters = filteredChapters.sorted { $0.position < $1.position }
        
        return chapterOrder == .reversed ? orderedChapters.reversed() : orderedChapters
    }
    
    func genres() -> [MangaGenre] {
        guard manga != nil else { return [] }
        guard manga!.genres?.count != 0 else { return [] }
        
        guard let genres = manga?.genres as? Set<MangaGenre> else { return [] }
        return genres.sorted { $0.name! < $1.name! }
    }
    
    func authors() -> [MangaAuthor] {
        guard manga != nil else { return [] }
        guard manga!.authors?.count != 0 else { return [] }
        
        guard let authors = manga?.authors as? Set<MangaAuthor> else { return [] }
        return authors.sorted { $0.name! < $1.name! }
    }
    
    func selectChapter(for chapter: MangaChapter) {
        selectedChapter = chapter
    }
    
    func getMangaURL() -> URL {
        return self.src.mangaUrl(mangaId: self.mangaId)
    }
    
    func getSourceName() -> String {
        return src.name
    }
    
    func changeChapterStatus(for chapter: MangaChapter, status: MangaChapter.Status) {
        chapter.status = status
        try? ctx.save()
        
        if libState.isMangaInCollection(for: manga!) {
            libState.reloadCollection()
        }
    }
    
    func changePreviousChapterStatus(for chapter: MangaChapter, status: MangaChapter.Status) {
        guard let rawChapters = manga?.chapters as? Set<MangaChapter> else { return }

        rawChapters
            .sorted { $0.position < $1.position }
            .filter { chapter.position < $0.position }
            .forEach { $0.status = status }
        
        try? ctx.save()
        
        if libState.isMangaInCollection(for: manga!) {
            libState.reloadCollection()
        }
    }
    
    func hasPreviousUnreadChapter(for chapter: MangaChapter) -> Bool {
        guard let chapters = manga?.chapters as? Set<MangaChapter> else { return false }

        return chapters
            .filter { chapter.position < $0.position }
            .contains { $0.status == .unread }
    }
    
    func resetCache() {
        guard self.manga != nil else { return }
        
        ctx.delete(manga!)
        
        self.manga = nil
        libState.saveLibraryState()
        
        async {
            await fetchAndInsert()
        }
    }
}
