//
//  MangaDetailVM.swift
//  Dokusho (iOS)
//
//  Created by Stephan Deumier on 14/06/2021.
//

import Foundation
import CoreData
import SwiftUI

@MainActor
class MangaDetailVM: ObservableObject {
    private var ctx = PersistenceController.shared.backgroundCtx()
    let src: SourceEntity
    let mangaId: String
    
    @Published var error = false
    @Published var manga: MangaEntity?
    @Published var showMoreDesc = false
    @Published var addToCollection = false
    @Published var refreshing = false
    
    init(for source: NSManagedObjectID, mangaId: String) {
        self.src = ctx.object(with: source) as! SourceEntity
        self.mangaId = mangaId

        withAnimation {
            self.manga = MangaEntity.fetchOne(ctx: ctx, mangaId: mangaId, source: src, includeChapters: true)
        }
    }
    
    func fetchManga() async {
        if manga == nil { await update() }
    }
    
    @MainActor
    func update() async {
        self.error = false
        self.refreshing = true

        do {
            guard let sourceManga = try? await src.getSource().fetchMangaDetail(id: mangaId) else { throw "Error fetch manga detail" }
            guard let saved = try? MangaEntity.updateFromSource(ctx: self.ctx, data: sourceManga, source: self.src) else { throw "Error updating/fetching manga" }
            try ctx.save()

            withAnimation {
                self.manga = saved
                self.refreshing = false
            }
        } catch {
            withAnimation {
                self.error = true
                self.refreshing = false
            }
        }
    }
    
    func getMangaURL() -> URL {
        return try! self.src.getSource().mangaUrl(mangaId: self.mangaId)
    }
    
    func getSourceName() -> String {
        return src.name ?? ""
    }
    
    // TODO: Rework reset cache to avoid deleting chapter read/unread info
    func resetCache() async {
//        guard let id = self.manga?.objectID else { return }
//
//        await fetchAndInsert()
    }
    
    func insertMangaInCollection(collectionId: NSManagedObjectID) {
        guard let collection = ctx.object(with: collectionId) as? CollectionEntity else { return }
        try? ctx.performAndWait {
            self.manga?.collection = collection
            try ctx.save()
        }
    }
    
    func removeMangaFromCollection() {
        try? ctx.performAndWait {
            self.manga?.collection = nil
            try self.ctx.save()
        }
    }
}
