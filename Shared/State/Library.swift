//
//  Library.swift
//  Dokusho (iOS)
//
//  Created by Stephan Deumier on 22/06/2021.
//

import Foundation
import CoreData

class LibraryState: ObservableObject {
    var ctx: NSManagedObjectContext

    @Published var collections = [MangaCollection]()
    @Published var isRefreshing = false
    @Published var refreshCount = 0
    @Published var refreshProgress = 0
    
    init(context ctx: NSManagedObjectContext) {
        self.ctx = ctx
        
        self.reloadCollection()
    }
    
    func addCollection(name: String) {
        let collection = MangaCollection(context: self.ctx)
        collection.id = UUID()
        collection.name = name
        saveLibraryState()
    }

    func updateCollection(collection: MangaCollection, newName: String) {
        collection.name = newName
        saveLibraryState()
    }
    
    // TODO: move manga in collection to another if manga inside
    func deleteCollection(collection: MangaCollection) {
        ctx.delete(collection)
        saveLibraryState()
    }
    
    func reloadCollection() {
        DispatchQueue.main.async {
            self.collections = try! self.ctx.fetch(MangaCollection.fetchRequest())
        }
    }
    
    func isMangaInCollection(for manga: Manga) -> Bool {
        var found = false
        for collection in collections {
            collection.mangas?.forEach { m in
                if (m.id == manga.id && m.source == manga.source) { found = true}
            }
        }
        
        return found
    }
    
    func isMangaInCollection(for manga: SourceSmallManga) -> Bool {
        return collections.contains { collection in
            guard let mangas = collection.mangas else { return false }
            
            return mangas.contains { $0.id == manga.id }
        }
    }
    
    func addMangaToCollection(manga: Manga, collection: MangaCollection) {
        collection.addToCollection(manga)
        saveLibraryState()
    }
    
    func addMangaToCollection(smallManga: SourceSmallManga, source: Source, collection: MangaCollection) async {
        do {
            let sourceManga = try await source.fetchMangaDetail(id: smallManga.id)
            let manga = Manga.fromSource(for: sourceManga, source: source, context: ctx)
            addMangaToCollection(manga: manga, collection: collection)
        } catch {
            print(error)
        }
    }
    
    func deleteMangaFromCollection(manga: Manga, collection: MangaCollection) {
        collection.removeFromCollection(manga)
        saveLibraryState()
    }
    
    func saveLibraryState() {
        do {
            try ctx.save()
            reloadCollection()
        } catch {
            print(error)
        }
    }
    
    // TODO: Can crash sometimes, don't know why tought
    func refreshManga(for collection: MangaCollection) {
        guard let mangas = collection.mangas else { return }
        guard !mangas.isEmpty else { return }
        isRefreshing = true
        refreshCount = mangas.count
        refreshProgress = 0

        async {
            for manga in mangas {
                do {
                    print("updating: \(manga.title!)")
                    let src = MangaSourceService.shared.getSource(sourceId: manga.source)
                    guard let src = src else { continue }
                    
                    let sourceManga = try await src.fetchMangaDetail(id: manga.id!)
                    let _ = manga.updateFromSource(for: sourceManga, source: src, context: ctx)

                    DispatchQueue.main.async { self.refreshProgress += 1 }
                }
                catch {
                    print(error)
                }
            }

            saveLibraryState()
            
            DispatchQueue.main.async { self.isRefreshing = false }
            print("done")
        }
    }
}
