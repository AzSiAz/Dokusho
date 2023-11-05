import Foundation
import SwiftUI
import DataKit
import SharedUI
import SerieDetail

struct SelectedSearchResult: Hashable {
    var scraperId: UUID
    var serieId: String
}

public struct SearchSourceListScreen: View {
    @Query(ScrapersRequest(filter: .active)) var scrapers: [Scraper]

    @State var searchText: String = ""
    
    public init() {}

    public var body: some View {
        List {
            if !searchText.isEmpty {
                ForEach(scrapers) { scraper in
                    Section(scraper.name) {
//                        ScraperSearch(scraper: Bindable(scraper), textToSearch: $searchText)
                    }
                    .listSectionSeparator(.hidden)
                }
            }
        }
        .listStyle(.plain)
        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
        .navigationDestination(for: SelectedSearchResult.self) { result in
            SerieDetailScreen(serieID: result.serieId, scraperID: result.scraperId)
        }
        .navigationTitle(Text("Search"))
        .navigationBarTitleDisplayMode(.inline)
        .overlay {
            if searchText.isEmpty {
                ContentUnavailableView.search
            }
        }
    }
}
