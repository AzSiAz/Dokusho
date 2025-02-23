import Foundation
import MangaScraper
import SwiftUI
import DataKit

class SearchScraperVM: ObservableObject {
    private var database = AppDatabase.shared.database
    
    var scraper: Scraper
    var nextPage = 1
    var oldSearch: String?
    
    @Published var isLoading = true
    @Published var hasNextPage = false
    @Published var mangas = [SourceSmallManga]()
    @Published var selectedManga: SourceSmallManga?
    
    init(scraper: Scraper) {
        self.scraper = scraper
    }
    
    @MainActor
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
    
    @MainActor
    func fetchMoreIfPossible(for manga: SourceSmallManga) async {
        guard let oldSearch = oldSearch else { return }

        if mangas.last == manga && hasNextPage {
            return await fetchData(textToSearch: oldSearch)
        }
    }
    
    @MainActor
    func addToCollection(smallManga: SourceSmallManga, collection: MangaCollection) async {
        guard let sourceManga = try? await scraper.asSource()?.fetchMangaDetail(id: smallManga.id) else { return }

        do {
            try await database.write { [scraper, smallManga, sourceManga, collection] db -> Void in
                guard var manga = try Manga.all().forMangaId(smallManga.id, scraper.id).fetchOne(db) else {
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
