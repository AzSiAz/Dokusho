//
//  MangaDetailVM.swift
//  Dokusho (iOS)
//
//  Created by Stephan Deumier on 14/06/2021.
//

import Foundation
import CoreData
import SwiftUI

class MangaDetailVM: ObservableObject {
    private var ctx = PersistenceController.shared.backgroundCtx()
    let src: SourceEntity
    let mangaId: String
    
    @Published var error = false
    @Published var manga: MangaEntity?
    @Published var showMoreDesc = false
    @Published var addToCollection = false
    @Published var refreshing = false
    
    init(for source: SourceEntity, mangaId: String) {
        self.src = source
        self.mangaId = mangaId
    }
    
    @MainActor
    func fetchManga() async {
        self.error = false

        manga = MangaEntity.fetchOne(ctx: ctx, mangaId: mangaId, source: src)

        if manga == nil { await update() }
    }
    
    @MainActor
    func update() async {
        self.manga = nil
        self.error = false
        self.refreshing = true

        do {
            let sourceManga = try await src.getSource().fetchMangaDetail(id: mangaId)

            try! ctx.performAndWait {
                self.manga = MangaEntity.updateFromSource(ctx: self.ctx, data: sourceManga, source: self.src)
                try self.ctx.save()
            }

            self.refreshing = false
        } catch {
            self.error = true
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
}

