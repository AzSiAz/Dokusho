//
//  SearchScraperVM.swift
//  Dokusho
//
//  Created by Stephan Deumier on 21/04/2022.
//

import Foundation
import MangaScraper
import SwiftUI
import DataKit

@MainActor
@Observable
class SearchScraperViewModel {
    private var database = AppDatabase.shared.database
    private var nextPage = 1
    private var oldSearch: String?
    
    let scraper: ScraperDB
    var isLoading = true
    var hasNextPage = false
    var mangas = [SourceSmallManga]()
    var selectedManga: SourceSmallManga?
    
    init(scraper: ScraperDB) {
        self.scraper = scraper
    }
    
    func fetchData(textToSearch: String) async {
        guard !textToSearch.isEmpty else { return }

        do {
            isLoading = true

            if oldSearch != textToSearch {
                self.mangas = []
                self.hasNextPage = false
                self.nextPage = 1
            }
            
            guard let data = try await scraper.asSource()?.fetchSearchManga(query: textToSearch, page: nextPage) else { throw "Error searching for \(textToSearch)" }
            
            withAnimation {
                self.hasNextPage = data.hasNextPage
                self.mangas += data.mangas
                self.isLoading = false
                self.nextPage += 1
                self.oldSearch = textToSearch
            }
        } catch {
            print(error)
        }
    }
    
    func fetchMoreIfPossible(for manga: SourceSmallManga) async {
        guard let oldSearch = oldSearch else { return }

        if mangas.last == manga && hasNextPage {
            return await fetchData(textToSearch: oldSearch)
        }
    }

    func addToCollection(smallManga: SourceSmallManga, collection: MangaCollectionDB) async {
        guard let sourceManga = try? await scraper.asSource()?.fetchMangaDetail(id: smallManga.id) else { return }

        do {
            try await database.write { [scraper] db -> Void in
                guard var manga = try MangaDB.all().forMangaId(smallManga.id, scraper.id).fetchOne(db) else {
                    var manga = MangaDB(from: sourceManga, sourceId: scraper.id)
                    manga.mangaCollectionId = collection.id
                    try manga.save(db)
                    
                    for info in sourceManga.chapters.enumerated() {
                        let chapter = MangaChapterDB(from: info.element, position: info.offset, mangaId: manga.id, scraperId: scraper.id)
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
