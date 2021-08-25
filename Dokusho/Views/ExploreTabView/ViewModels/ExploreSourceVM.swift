//
//  ExploreDetailViewModels.swift
//  Dokusho (iOS)
//
//  Created by Stephan Deumier on 06/06/2021.
//

import Foundation
import SwiftUI
import CoreData
import MangaSources

class ExploreSourceVM: ObservableObject {
    private let ctx = PersistenceController.shared.backgroundCtx()
    
    let src: SourceEntity
    
    @Published var nextPage = 1
    @Published var mangas: [SourceSmallManga] = []
    @Published var error = false
    @Published var type: SourceFetchType = .latest
    @Published var selectedManga: SourceSmallManga?
    
    init(for source: SourceEntity) {
        self.src = source
    }
    
    @MainActor
    func fetchList(clean: Bool = false) async {
        if clean {
            mangas = []
            nextPage = 1
        }
        
        self.error = false
        
        do {
            let newManga = try await type == .latest
                ? src.getSource().fetchLatestUpdates(page: nextPage)
                : src.getSource().fetchPopularManga(page: nextPage)

            self.mangas += newManga.mangas
            self.nextPage += 1
        } catch {
            self.error = true
        }
    }
    
    @MainActor
    func fetchMoreIfPossible(for manga: SourceSmallManga) async {
        if mangas.last == manga {
            return await fetchList()
        }
    }
    
    func getTitle() -> String {
        return "\(src.name ?? "") - \(type.rawValue)"
    }
    
    func addToCollection(smallManga: SourceSmallManga, collection collectionId: NSManagedObjectID) async {
        guard let sourceManga = try? await src.getSource().fetchMangaDetail(id: smallManga.id) else { return }
//        await Manga.upsertFromSource(sourceData: sourceManga, source: src)
        try! await ctx.perform {
            let manga = MangaEntity.updateFromSource(ctx: self.ctx, data: sourceManga, source: self.src)
            guard let collection = self.ctx.object(with: collectionId) as? CollectionEntity else { return }
            
            collection.addToMangas(manga)
            
            try self.ctx.save()
        }
        
//        try? autoreleasepool {
//            let realm = try Realm()
//
//            try? realm.write {
//                guard let manga = realm.object(ofType: Manga.self, forPrimaryKey: Manga.getPrimaryKey(sourceId: src.sourceId, mangaId: sourceManga.id)) else {
//                    return
//                }
//                guard let collection = realm.resolve(trc) else { return }
//
//                collection.mangas.insert(manga)
//            }
//        }
    }
}
