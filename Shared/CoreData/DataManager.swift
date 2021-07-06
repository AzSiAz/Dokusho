//
//  Manager.swift
//  Dokusho (iOS)
//
//  Created by Stephan Deumier on 28/06/2021.
//

import Foundation
import CoreData
import SwiftUI

struct DataManager {
    static var shared: DataManager {
        let vc = PersistenceController.shared.container.viewContext

        return .init(ctx: vc)
    }
    
    var srcSvc = MangaSourceService.shared
    var ctx: NSManagedObjectContext
    
    func getManga(mangaId: String, sourceId: Int16) -> Manga? {
        return Manga.fetchOne(mangaId: mangaId, sourceId: sourceId, ctx: ctx)
    }
    
    func getMangas(mangaIds: [String], sourceId: Int16) -> [Manga] {
        
        return []
    }
    
    func getCollection(collectionId: UUID) -> MangaCollection? {
        return MangaCollection.fetchOne(collectionId: collectionId, ctx: ctx)
    }
    
    func getCollections() -> [MangaCollection]? {
        return MangaCollection.fetchMany(ctx: ctx)
    }
    
    func insertMangaInCollection(for manga: Manga, in newCollection: MangaCollection) {
        ctx.perform {
            if let oldCollection = manga.collection {
                oldCollection.removeFromCollection(manga)
            }
            manga.collection = newCollection
            newCollection.addToCollection(manga)

            saveChange()
        }
    }
    
    func removeMangaFromCollection(for manga: Manga, in collection: MangaCollection) {
        ctx.perform {
            manga.collection = nil
            collection.removeFromCollection(manga)
            
            saveChange()
        }
    }
    
    func insertManga(manga: SourceManga, source: Source, collection: MangaCollection?) {
        ctx.perform {
            let manga = Manga.createFromSource(for: manga, source: source, context: ctx)
            if let collection = collection {
                manga.collection = collection
            }
            
            saveChange()
        }
    }
    
    func insertManga(base: SourceSmallManga, source: Source, collection: MangaCollection?) async {
        guard let sourceManga = try? await source.fetchMangaDetail(id: base.id) else { return }

        await ctx.perform {
            let manga = Manga.createFromSource(for: sourceManga, source: source, context: ctx)

            if let collection = collection {
                manga.collection = collection
            }
            
            saveChange()
        }
    }
    
    func updateMangaWithSource(manga: Manga) async {
        do {
            guard let src = srcSvc.getSource(sourceId: manga.source) else { throw "Source Not Found" }
            guard let sourceManga = try? await src.fetchMangaDetail(id: manga.id!) else { throw "Source Manga not found" }

            await ctx.perform {
                let _ = manga.updateFromSource(for: sourceManga, source: src, context: ctx)
                saveChange()
            }
        } catch {
            print(error)
        }
    }
    
    /// Also remove from collection
    func cleanMangaFromDB(manga: Manga) {
        ctx.perform {
            ctx.delete(manga)
            saveChange()
        }
    }
    
    func addCollection(name: String, position: Int16) {
        ctx.perform {
            let _ = MangaCollection(context: ctx, name: name, position: position)
            saveChange()
        }
    }
    
    func updateCollection(collection: MangaCollection, newName: String) {
        ctx.perform {
            collection.name = newName
            saveChange()
        }
    }
    
    func updateCollection(collection: MangaCollection, newFilterState: MangaCollection.Filter) {
        ctx.perform {
            collection.filter = newFilterState
            saveChange()
        }
    }

    // TODO: To fix someday, lol
    func reorderCollection(from source: IndexSet, to before: Int, within: FetchedResults<MangaCollection> ) {
        
        let firstIndex = source.min()!
        let lastIndex = source.max()!
        
        let firstRowToReorder = (firstIndex < before) ? firstIndex : before
        let lastRowToReorder = (lastIndex > (before-1)) ? lastIndex : (before-1)
        
        if firstRowToReorder != lastRowToReorder {
            
            ctx.perform {
                var newOrder = firstRowToReorder
                if newOrder < firstIndex {
                    // Moving dragged items up, so re-order dragged items first
                    // Re-order dragged items
                    for index in source {
                        within[index].setValue(newOrder, forKey: "position")
                        newOrder = newOrder + 1
                    }
                    
                    // Re-order non-dragged items
                    for rowToMove in firstRowToReorder..<lastRowToReorder {
                        if !source.contains(rowToMove) {
                            within[rowToMove].setValue(newOrder, forKey: "position")
                            newOrder = newOrder + 1
                        }
                    }
                } else {
                    // Moving dragged items down, so re-order dragged items last
                    // Re-order non-dragged items
                    for rowToMove in firstRowToReorder...lastRowToReorder {
                        if !source.contains(rowToMove) {
                            within[rowToMove].setValue(newOrder, forKey: "position")
                            newOrder = newOrder + 1
                        }
                    }
                    
                    // Re-order dragged items
                    for index in source {
                        within[index].setValue(newOrder, forKey: "position")
                        newOrder = newOrder + 1
                    }
                }
                
                saveChange()
            }
        }
    }
    
    // TODO: move manga in collection to another if manga inside
    func deleteCollection(collection: MangaCollection) {
        ctx.perform {
            ctx.delete(collection)
            saveChange()
        }
    }
    
    // TODO: Can crash sometimes, don't know why tought
    func refreshCollection(for collection: MangaCollection, onProgress: @escaping (Int, Int, String) -> Void) async {
        guard let mangas = collection.mangas else { return }
        guard !mangas.isEmpty else { return }
        
        let count = mangas.count
        var progress = 0
        
        for manga in mangas {
            progress += 1
            onProgress(progress, count, manga.title ?? "No title")
            
            guard let src = srcSvc.getSource(sourceId: manga.source) else { continue }
            guard let sourceManga = try? await src.fetchMangaDetail(id: manga.id!) else { continue }
            
            ctx.performAndWait {
                let _ = manga.updateFromSource(for: sourceManga, source: src, context: ctx)
                saveChange()
            }
        }
    }
    
    func isMangaInCollection(for manga: Manga) -> Bool {
        return manga.collection != nil
    }

    func isMangaInCollection(for manga: SourceSmallManga, source: Source) -> Bool {
        return Manga.fetchOne(mangaId: manga.id, sourceId: source.id, ctx: ctx)?.collection != nil
    }
    
    func markChaptersAllAs(for manga: Manga, status: MangaChapter.Status) {
        ctx.perform {
            manga.chapters?.forEach {
                if status == .read { $0.readAt = .now }
                if status == .unread { $0.readAt = nil }

                $0.status = status
                $0.manga?.lastUserAction = .now
            }
            saveChange()
        }
    }
    
    func markChapterAs(chapter: MangaChapter, status: MangaChapter.Status) {
        ctx.perform {
            if status == .read { chapter.readAt = .now }
            if status == .unread { chapter.readAt = nil }
            
            chapter.status = status
            chapter.manga?.lastUserAction = .now
            
            saveChange()
        }
    }
    
    func saveChange() {
        do {
            try ctx.save()
        } catch {
            print(error)
        }
    }
}
