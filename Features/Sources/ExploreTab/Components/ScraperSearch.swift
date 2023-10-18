import Foundation
import SwiftUI
import DataKit
import SharedUI
import SerieDetail
import Collections

public struct ScraperSearch: View {
    @Environment(ScraperService.self) var scraperService
    
    @Query var seriesInCollection: [Serie]
    @Query(.allSerieCollectionByPosition(.forward)) var collections: [SerieCollection]

    @Bindable private var scraper: Scraper
    @Binding var text: String
    
    @State private var nextPage = 1
    @State private var oldSearch: String?
    @State private var isLoading = true
    @State private var hasNextPage = false
    @State private var mangas = OrderedSet<SourceSmallSerie>()
    
    public init(scraper: Bindable<Scraper>, textToSearch: Binding<String>) {
        _scraper = scraper
        _text = textToSearch
        _seriesInCollection = Query(.seriesInCollection(scraperId: scraper.id))
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
            SerieList(series: mangas, horizontal: true) { serie in
                NavigationLink(value: SelectedSearchResult(scraperId: scraper.id, serieId: serie.id)) {
                    let found = seriesInCollection.first { $0.internalId == serie.id }
                    SerieCard(title: serie.title, imageUrl: serie.thumbnailUrl, collectionName: found?.collection?.name)
                        .contextMenu { ContextMenu(serie: serie) }
                        .task { await fetchMoreIfPossible(for: serie) }
                }
            }
        }
    }
    
    @ViewBuilder
    func ContextMenu(serie: SourceSmallSerie) -> some View {
        ForEach(collections) { collection in
            AsyncButton(action: { await addToCollection(id: serie.id, collection: collection) }) {
                Text("Add to \(collection.name ?? "")")
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
            let data = try? await source.fetchSearchSerie(query: text, page: nextPage)
        else { return }
        
        withAnimation {
            self.hasNextPage = data.hasNextPage
            self.mangas.append(contentsOf: data.data)
            self.isLoading = false
            self.nextPage += 1
            self.oldSearch = text
        }
    }
    
    func fetchMoreIfPossible(for manga: SourceSmallSerie) async {
        guard let oldSearch = oldSearch else { return }

        if mangas.last == manga && hasNextPage {
            return await fetchData(text: oldSearch)
        }
    }
    
    func addToCollection(id: SourceSmallSerie.ID, collection: SerieCollection) async {
        guard
            let source = scraperService.getSource(sourceId: scraper.id),
            let sourceManga = try? await source.fetchSerieDetail(serieId: id)
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
