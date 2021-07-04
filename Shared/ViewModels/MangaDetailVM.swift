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
    let src: Source
    let ctx = PersistenceController.shared.container.viewContext
    let mangaId: String
    
    private let mangaController: NSFetchedResultsController<Manga>
    private let dataManager = DataManager.shared

    @Published var error = false
    @Published var manga: Manga?
    
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
        self.manga = mangaController.fetchedObjects?.first

        if manga == nil { await fetchAndInsert() }
    }
    
    func fetchAndInsert() async {
        self.error = false
        self.manga = nil

        do {
            let sourceManga = try await src.fetchMangaDetail(id: mangaId)
            
            try ctx.performAndWait {
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
    
    func getMangaURL() -> URL {
        return self.src.mangaUrl(mangaId: self.mangaId)
    }
    
    func getSourceName() -> String {
        return src.name
    }
    
    func resetCache() {
        guard let m = self.manga else { return }
        manga = nil
        
        ctx.performAndWait {
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

