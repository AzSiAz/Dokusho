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
    private let database = AppDatabase.shared.database

    let scraper: Scraper
    
    @Published var nextPage = 1
    @Published var mangas: [SourceSmallManga] = []
    @Published var error = false
    @Published var type: SourceFetchType = .latest
    @Published var selectedManga: SourceSmallManga?
    
    init(for scraper: Scraper) {
        self.scraper = scraper
    }
    
    @MainActor
    func fetchList(clean: Bool = false) async {
        if clean {
            mangas = []
            nextPage = 1
        }
        
        self.error = false
        
        do {
            let newManga = try await type == .latest ? scraper.asSource()?.fetchLatestUpdates(page: nextPage) :  scraper.asSource()?.fetchPopularManga(page: nextPage)

            self.mangas += newManga!.mangas
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
        return "\(scraper.name) - \(type.rawValue)"
    }
    
    func addToCollection(smallManga: SourceSmallManga, collection: MangaCollection) async {
        guard let sourceManga = try? await scraper.asSource()?.fetchMangaDetail(id: smallManga.id) else { return }

        do {
            try database.write { db -> Void in
                // TODO: Investigate why I can't use `Manga.filter`
                guard var manga = try Manga.fetchOne(db, key: ["mangaId": sourceManga.id, "scraperId": scraper.id]) else {
                    var manga = Manga(from: sourceManga, sourceId: scraper.id)
                    manga.mangaCollectionId = collection.id
                    try manga.save(db)
                    
                    for info in sourceManga.chapters.enumerated() {
                        let chapter = MangaChapter(from: info.element, position: info.offset, mangaId: manga.id, scraperId: scraper.id)
                        try chapter.save(db)
                    }

                    return
                }

                manga.mangaCollectionId = collection.id

                return try manga.save(db)
            }
        } catch(let err) {
            print(err)
        }
    }
}
