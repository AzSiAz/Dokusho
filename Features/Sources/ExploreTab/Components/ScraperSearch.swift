import Foundation
import SwiftUI
import DataKit
import SharedUI
import SerieDetail
import Collections

public struct ScraperSearch: View {
    @Environment(ScraperService.self) var scraperService
    @Environment(SerieService.self) var serieService
    
    @Harmony var harmony

    @Query<SerieInCollectionsForScraperRequest> var inCollection: [SerieInCollection]
    @Query(AllSerieCollectionRequest()) var collections

    private var scraper: Scraper
    private var text: String
 
    @State private var nextPage = 1
    @State private var oldSearch: String?
    @State private var isLoading = true
    @State private var hasNextPage = false
    @State private var series = OrderedSet<SourceSmallSerie>()

    public init(scraper: Scraper, textToSearch: String) {
        self.scraper = scraper
        self.text = textToSearch
        self._inCollection = Query(SerieInCollectionsForScraperRequest(scraperID: scraper.id))
    }
    
    public var body: some View {
        Group {
            if isLoading && series.isEmpty {
                ProgressView()
            } else if !isLoading && series.isEmpty {
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
            SerieList(series: series, horizontal: true) { serie in
                NavigationLink(value: SelectedSearchResult(scraperId: scraper.id, serieInternalID: serie.id)) {
                    let found = inCollection.first { $0.internalID == serie.id }
                    SerieCard(title: serie.title, imageUrl: serie.thumbnailUrl, collectionName: found?.collection)
                        .contextMenu { ContextMenu(serie: serie) }
                        .task { await fetchMoreIfPossible(for: serie) }
                        .serieCardFrame()
                }
            }
        }
    }
    
    @ViewBuilder
    func ContextMenu(serie: SourceSmallSerie) -> some View {
        ForEach(collections) { collection in
            AsyncButton(action: { await addToCollection(id: serie.id, serieCollection: collection) }) {
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
            series = []
            hasNextPage = false
            nextPage = 1
        }
        
        guard
            let source = scraperService.getSource(sourceId: scraper.id),
            let data = try? await source.fetchSearchSerie(query: text, page: nextPage)
        else { return }
        
        withAnimation {
            self.hasNextPage = data.hasNextPage
            self.series.append(contentsOf: data.data)
            self.isLoading = false
            self.nextPage += 1
            self.oldSearch = text
        }
    }
    
    func fetchMoreIfPossible(for serie: SourceSmallSerie) async {
        guard let oldSearch = oldSearch else { return }

        if series.last == serie && hasNextPage {
            return await fetchData(text: oldSearch)
        }
    }
    
    func addToCollection(id: SourceSmallSerie.ID, serieCollection: SerieCollection) async {
        guard
            let source = scraperService.getSource(sourceId: scraper.id)
        else {  return }

        try? await serieService.addSerieToCollection(
            source: source,
            serieInternalID: id,
            serieCollectionID: serieCollection.id,
            harmonic: harmony
        )
    }
}
