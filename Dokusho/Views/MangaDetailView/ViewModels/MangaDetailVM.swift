//
//  MangaDetailVM.swift
//  Dokusho (iOS)
//
//  Created by Stephan Deumier on 14/06/2021.
//

import Foundation
import CoreData
import SwiftUI
import MangaScraper
import WidgetKit

@MainActor
class MangaDetailVM: ObservableObject {
    private var ctx = PersistenceController.shared.container.viewContext
    let src: Source
    let mangaId: String
    let showDismiss: Bool
    
    @Published var error = false
    @Published var manga: MangaEntity?
    @Published var showMoreDesc = false
    @Published var addToCollection = false
    @Published var refreshing = false
    @Published var selectedChapter: ChapterEntity?
    @Published var isInCollectionPage: Bool
    
    init(for sourceId: UUID, mangaId: String, showDismiss: Bool, isInCollectionPage: Bool = false) {
        self.src = MangaScraperService.shared.getSource(sourceId: sourceId)!
        self.mangaId = mangaId
        self.showDismiss = showDismiss
        self.isInCollectionPage = isInCollectionPage

        withAnimation {
            self.manga = MangaEntity.fetchOne(ctx: ctx, mangaId: mangaId, sourceId: src.id, includeChapters: true)
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
            guard let sourceManga = try? await src.fetchMangaDetail(id: mangaId) else { throw "Error fetch manga detail" }
            guard let saved = try? MangaEntity.updateFromSource(ctx: self.ctx, data: sourceManga, source: self.src) else { throw "Error updating/fetching manga" }
            try ctx.save()

            withAnimation {
                self.manga = saved
                self.refreshing = false
            }
            
            Task(priority: .low) {
                WidgetCenter.shared.reloadTimelines(ofKind: WidgetKind.latestMangaWidget.rawValue)
            }
        } catch {
            withAnimation {
                self.error = true
                self.refreshing = false
            }
        }
    }
    
    func getMangaURL() -> URL {
        return self.src.mangaUrl(mangaId: self.mangaId)
    }
    
    func getSourceName() -> String {
        return src.name
    }
    
    // TODO: Rework reset cache to avoid deleting chapter read/unread info
    func resetCache() async {
//        guard let id = self.manga?.objectID else { return }
//
//        await fetchAndInsert()
    }
    
    func insertMangaInCollection(_ collectionId: NSManagedObjectID) {
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
