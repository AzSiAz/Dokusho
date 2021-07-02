//
//  MangaDetailVM.swift
//  Dokusho (iOS)
//
//  Created by Stephan Deumier on 14/06/2021.
//

import Foundation
import CoreData

@MainActor
class MangaDetailVM: NSObject, ObservableObject {
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
    let ctx = PersistenceController.shared.container.viewContext
    let mangaId: String
    
    private let mangaController: NSFetchedResultsController<Manga>
    private let dataManager = DataManager.shared

    @Published var error = false
    @Published var manga: Manga?
    @Published var selectedChapter: MangaChapter?
    @Published var chapterOrder: ChapterOrder = .base
    @Published var chapterFilter: ChapterFilter = .all
    
    init(for source: Source, mangaId: String) {
        self.mangaController = NSFetchedResultsController(
            fetchRequest: Manga.mangaOneFetch(mangaId: mangaId, srcId: source.id),
            managedObjectContext: PersistenceController.shared.container.viewContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        self.src = source
        self.mangaId = mangaId
        
        super.init()
        
        mangaController.delegate = self
    }
    
    func fetchManga() async {
        self.error = false

        try? self.mangaController.performFetch()

        if manga == nil { await fetchAndInsert() }
    }
    
    func fetchAndInsert() async {
        self.error = false
        self.manga = nil
        // TODO: Fix

        do {
            let sourceManga = try await src.fetchMangaDetail(id: mangaId)
            
            try await ctx.perform {
                self.manga = Manga.createFromSource(for: sourceManga, source: self.src, context: self.ctx)
                try self.ctx.save()
            }
        } catch {
            self.error = true
        }
    }
    
    func refresh() async {
        self.error = false

        do {
            let sourceManga = try await src.fetchMangaDetail(id: mangaId)
            try await ctx.perform {
                self.manga = self.manga?.updateFromSource(for: sourceManga, source: self.src, context: self.ctx)
                try self.ctx.save()
            }
        } catch {
            self.error = true
        }
    }
    
    func chapters() -> [MangaChapter] {
        guard manga != nil else { return [] }
        guard manga!.chapters?.count != 0 else { return [] }
        
        guard let chapters = manga?.chapters else { return [] }
        
        let filteredChapters = chapters.filter { self.chapterFilter == .all ? true : $0.status.isUnread() }
        let orderedChapters = filteredChapters.sorted { $0.position < $1.position }
        
        return chapterOrder == .reversed ? orderedChapters.reversed() : orderedChapters
    }
    
    func genres() -> [MangaGenre] {
        guard manga != nil else { return [] }
        guard manga!.genres?.count != 0 else { return [] }
        
        guard let genres = manga?.genres else { return [] }
        return genres.sorted { $0.name! < $1.name! }
    }
    
    func authors() -> [MangaAuthor] {
        guard manga != nil else { return [] }
        guard manga!.authors?.count != 0 else { return [] }
        
        guard let authors = manga?.authors else { return [] }
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
    }
    
    func changePreviousChapterStatus(for chapter: MangaChapter, status: MangaChapter.Status) {
        guard let rawChapters = manga?.chapters else { return }

        ctx.perform {
            rawChapters
                .sorted { $0.position < $1.position }
                .filter { chapter.position < $0.position }
                .forEach { $0.status = status }
            
            try? self.ctx.save()
        }
    }
    
    func hasPreviousUnreadChapter(for chapter: MangaChapter) -> Bool {
        guard let chapters = manga?.chapters else { return false }

        return chapters
            .filter { chapter.position < $0.position }
            .contains { $0.status == .unread }
    }
    
    func resetCache() {
        guard let m = self.manga else { return }
        manga = nil
        
        ctx.perform {
            self.ctx.delete(m)
            try? self.ctx.save()
        }
        
        async {
            await fetchAndInsert()
        }
    }
}

extension MangaDetailVM: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        guard let mangas = controller.fetchedObjects as? [Manga] else { return }
        
        self.manga = mangas.first
    }
}

