//
//  ExploreDetailViewModels.swift
//  Dokusho (iOS)
//
//  Created by Stephan Deumier on 06/06/2021.
//

import Foundation
import SwiftUI
import CoreData
import MangaScraper

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

        try! await ctx.perform {
            guard let manga = try? MangaEntity.updateFromSource(ctx: self.ctx, data: sourceManga, source: self.src) else { return }
            guard let collection = self.ctx.object(with: collectionId) as? CollectionEntity else { return }
            
            collection.addToMangas(manga)
            
            try self.ctx.save()
        }
    }
}
