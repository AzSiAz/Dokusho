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
    let ctx = PersistenceController.shared.container.viewContext
    private let dataManager = DataManager.shared
    
    let src: Source
    let mangaId: String
    @Published var error = false
    @Published var manga: Manga?
    
    init(for source: Source, mangaId: String) {
        self.src = source
        self.mangaId = mangaId
    }
    
    func fetchManga() async {
        self.error = false
        
        self.manga = Manga.fetchOne(mangaId: mangaId, sourceId: src.id, ctx: ctx)
        
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

