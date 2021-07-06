//
//  ChapterListVM.swift
//  Dokusho
//
//  Created by Stephan Deumier on 04/07/2021.
//

import Foundation
import CoreData

class ChapterListVM: NSObject, ObservableObject {
    private let dataManager = DataManager.shared
    private let ctx = PersistenceController.shared.container.viewContext
    
    var mangaId: String
    @Published var chapters: [MangaChapter] = []
    @Published var selectedChapter: MangaChapter?
    @Published var filter: MangaChapter.StatusFilter
    @Published var ascendingOrder: Bool
    @Published var error: Error?
    
    private var chaptersController: NSFetchedResultsController<MangaChapter> = .init()
    
    init(mangaId: String, filter: MangaChapter.StatusFilter = .all, ascendingOrder: Bool = true) {
        self.mangaId = mangaId
        self.filter = filter
        self.ascendingOrder = ascendingOrder
        
        super.init()
    }
    
    func fetchCollection() {
        chaptersController = NSFetchedResultsController(
            fetchRequest: MangaChapter.fetchChaptersForManga(mangaId: self.mangaId, status: self.filter, ascending: self.ascendingOrder),
            managedObjectContext: PersistenceController.shared.container.viewContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        chaptersController.delegate = self
        
        do {
            try chaptersController.performFetch()
            chapters = chaptersController.fetchedObjects ?? []
        } catch {
            self.error = error
        }
    }
    
    func toggleFilter() {
        self.filter.toggle()
        fetchCollection()
    }
    
    func toggleOrder() {
        self.ascendingOrder.toggle()
        fetchCollection()
    }
    
    func selectChapter(for chapter: MangaChapter) {
        selectedChapter = chapter
    }
    
    func changeChapterStatus(for chapter: MangaChapter, status: MangaChapter.Status) {
        ctx.performAndWait {
            if status == .read { chapter.readAt = .now }
            if status == .unread { chapter.readAt = nil }
            
            chapter.status = status
            try? self.ctx.save()
        }
        
        fetchCollection()
    }
    
    func changePreviousChapterStatus(for chapter: MangaChapter, status: MangaChapter.Status) {
        ctx.performAndWait {
            self.chapters
                .sorted { $0.position < $1.position }
                .filter { chapter.position < $0.position }
                .forEach {
                    if status == .read { $0.readAt = .now }
                    if status == .unread { $0.readAt = nil }
                    
                    $0.status = status
                }
            
            try? self.ctx.save()
        }
        
        fetchCollection()
    }
    
    func hasPreviousUnreadChapter(for chapter: MangaChapter) -> Bool {
        return chapters
            .filter { chapter.position < $0.position }
            .contains { $0.status == .unread }
    }
    
    func nextUnreadChapter() -> MangaChapter? {
        let sort = SortDescriptor(\MangaChapter.position, order: .reverse)
        return chapters.sorted(using: sort).first { $0.status == .unread }
    }
}

extension ChapterListVM: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        guard let chapters = controller.fetchedObjects as? [MangaChapter] else { return }
        
        self.chapters = chapters
    }
}
