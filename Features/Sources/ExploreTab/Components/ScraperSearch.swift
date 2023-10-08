import Foundation
import SwiftUI
import MangaScraper
import DataKit
import SharedUI
import MangaDetail
import Collections

public struct ScraperSearch: View {
    @Environment(ScraperService.self) var scraperService
    
    @Query var mangasInCollection: [Manga]
    @Query(.allMangaCollectionByPosition(.forward)) var collections: [MangaCollection]

    @Bindable private var scraper: Scraper
    @Binding var text: String
    
    @State private var nextPage = 1
    @State private var oldSearch: String?
    @State private var isLoading = true
    @State private var hasNextPage = false
    @State private var mangas = OrderedSet<SourceSmallManga>()
    
    public init(scraper: Bindable<Scraper>, textToSearch: Binding<String>) {
        _scraper = scraper
        _text = textToSearch
        _mangasInCollection = Query(.mangaInCollection(scraperId: scraper.id))
    }
    
    public var body: some View {
        Group {
            if isLoading && mangas.isEmpty {
                ProgressView()
            } else if !isLoading && mangas.isEmpty {
                Text("No Results founds")
            }
            else {
                SearchResult()
            }
        }
        .frame(width: .greedy)
        .task(id: text) {
            try? await Task.sleep(for: .seconds(0.3))
            await fetchData(text: text)
        }
    }
    
    @ViewBuilder
    func SearchResult() -> some View {
        ScrollView(.horizontal, showsIndicators: true) {
            MangaList(mangas: mangas, horizontal: true) { manga in
                NavigationLink(value: SelectedSearchResult(scraperId: scraper.id, mangaId: manga.id)) {
                    let found = mangasInCollection.first { $0.mangaId == manga.id }
                    MangaCard(title: manga.title, imageUrl: manga.thumbnailUrl, collectionName: found?.collection?.name)
                        .contextMenu { ContextMenu(manga: manga) }
                        .task { await fetchMoreIfPossible(for: manga) }
                }
            }
        }
    }
    
    @ViewBuilder
    func ContextMenu(manga: SourceSmallManga) -> some View {
        ForEach(collections) { collection in
            AsyncButton(action: { await addToCollection(id: manga.id, collection: collection) }) {
                Text("Add to \(collection.name)")
            }
        }
    }
}

extension ScraperSearch {
    func fetchData(text: String) async {
        guard !text.isEmpty else { return }

        isLoading = true

        if oldSearch != text {
            mangas = []
            hasNextPage = false
            nextPage = 1
        }
        
        guard
            let source = scraperService.getSource(sourceId: scraper.id),
            let data = try? await source.fetchSearchManga(query: text, page: nextPage)
        else { return }
        
        withAnimation {
            self.hasNextPage = data.hasNextPage
            self.mangas.append(contentsOf: data.mangas)
            self.isLoading = false
            self.nextPage += 1
            self.oldSearch = text
        }
    }
    
    func fetchMoreIfPossible(for manga: SourceSmallManga) async {
        guard let oldSearch = oldSearch else { return }

        if mangas.last == manga && hasNextPage {
            return await fetchData(text: oldSearch)
        }
    }
    
    func addToCollection(id: SourceSmallManga.ID, collection: MangaCollection) async {
        guard
            let source = scraperService.getSource(sourceId: scraper.id),
            let sourceManga = try? await source.fetchMangaDetail(id: id)
        else {  return }
        
        print(sourceManga)

//        do {
//            try await database.write { [scraper] db -> Void in
//                guard var manga = try MangaDB.all().forMangaId(smallManga.id, scraper.id).fetchOne(db) else {
//                    var manga = MangaDB(from: sourceManga, sourceId: scraper.id)
//                    manga.mangaCollectionId = collection.id
//                    try manga.save(db)
//
//                    for info in sourceManga.chapters.enumerated() {
//                        let chapter = MangaChapterDB(from: info.element, position: info.offset, mangaId: manga.id, scraperId: scraper.id)
//                        try chapter.save(db)
//                    }
//
//                    return
//                }
//
//                manga.mangaCollectionId = collection.id
//
//                return try manga.save(db)
//            }
//        } catch(let err) {
//            print(err)
//        }
    }
}
