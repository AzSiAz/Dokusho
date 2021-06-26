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
    
    init(context ctx: NSManagedObjectContext) {
        self.ctx = ctx
        
        self.reloadCollection()
    }
    
    func addCollection(name: String) {
        let collection = MangaCollection(context: self.ctx)
        collection.id = UUID()
        collection.name = name
        try? ctx.save()
        
        reloadCollection()
    }

    func updateCollection(collection: MangaCollection, newName: String) {
        collection.name = newName
        try? ctx.save()

        reloadCollection()
    }
    
    // TODO: move manga in collection to another if manga inside
    func deleteCollection(collection: MangaCollection) {
        ctx.delete(collection)
        try? ctx.save()
        
        reloadCollection()
    }
    
    func reloadCollection() {
        collections = try! self.ctx.fetch(MangaCollection.fetchRequest())
    }
    
    func isMangaInCollection(for manga: Manga) -> Bool {
        var found = false
        for collection in collections {
            collection.mangas?.forEach { m in
                if ((m as? Manga)?.id == manga.id && (m as? Manga)?.source == manga.source) { found = true}
            }
        }
        
        return found
    }
    
    func isMangaInCollection(for manga: SourceSmallManga) -> Bool {
        return collections.contains { collection in
            guard let mangas = collection.mangas as? Set<Manga> else { return false }
            
            return mangas.contains { $0.id == manga.id }
        }
    }
    
    func addMangaToCollection(manga: Manga, collection: MangaCollection) {
        collection.addToMangas(manga)
        try? ctx.save()
        
        reloadCollection()
    }
    
    func deleteMangaFromCollection(manga: Manga, collection: MangaCollection) {
        collection.removeFromMangas(manga)
        try? ctx.save()
        
        reloadCollection()
    }
    
    func saveLibraryState() {
        try? ctx.save()

        reloadCollection()
    }
}
