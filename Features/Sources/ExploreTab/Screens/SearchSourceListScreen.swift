import Foundation
import SwiftUI
import DataKit
import SharedUI
import MangaDetail

struct SelectedSearchResult: Hashable {
    var scraperId: UUID
    var mangaId: String
}

public struct SearchSourceListScreen: View {
    @Query(.activeScrapersByPosition()) var scrapers: [Scraper]
    
    @State var searchText: String = ""
    @State var isSearchFocused: Bool = true
    
    public init() {}

    public var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            ForEach(scrapers) { scraper in
                ScraperSearch(scraper: Bindable(scraper), textToSearch: $searchText)
            }
        }
        .searchable(text: $searchText)
        .navigationDestination(for: SelectedSearchResult.self) { result in
            MangaDetailScreen(mangaId: result.mangaId, scraperId: result.scraperId)
        }
        .navigationTitle(Text("Search"))
        .navigationBarTitleDisplayMode(.inline)
    }
}
