//
//  MangaDetailVM.swift
//  Dokusho (iOS)
//
//  Created by Stephan Deumier on 14/06/2021.
//

import Foundation

class MangaDetailVM: ObservableObject {
    let src: Source
    let mangaId: String

    @Published var error = false
    @Published var manga: SourceManga?
    
    init(for source: Source, mangaId: String) {
        self.src = source
        self.mangaId = mangaId
    }
    
    func fetchManga() async {
        self.error = false
        do {
            // TODO: Fetch from CoreData before and only fetch from source on refresh
            manga = try await src.fetchMangaDetail(id: mangaId)
//            chapters = manga!.chapters
//            manga?.chapters = []
        } catch {
            self.error = true
        }
    }
    
    func reverseChaptersOrder() {
        if manga != nil {
            manga!.chapters = manga!.chapters.reversed()
        }
    }
    
    func getMangaURL() -> URL {
        return self.src.mangaUrl(mangaId: self.mangaId)
    }
    
    func getSourceName() -> String {
        return src.name
    }
}
