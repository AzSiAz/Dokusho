import SwiftUI
import SerieScraper
import DataKit
import SharedUI

public struct ExploreTabView: View {
    @Harmony var harmony
    
    @Environment(ScraperService.self) var scrapersService

    @Query(ScrapersRequest(filter: .active)) var scrapers: [Scraper]

    @State var showSourceEdit: Bool = false
    @State var showSourceSearch: Bool = false

    public init() {}
    
    public var body: some View {
        NavigationStack {
            List {
                ForEach(scrapers) { scraper in
                    NavigationLink(value: scraper) {
                        ScraperRow(scraper: scraper)
                    }
                }
                .onMove { offsets, position in
                    Task { [offsets, position] in
                        await scrapersService.onMove(scrapers: scrapers, offsets: offsets, position: position, in: harmony)
                    }
                }
            }
            .overlay {
                if scrapers.isEmpty {
                    ContentUnavailableView("No Source", systemImage: "safari", description: Text("Please enable a source to explore"))
                }
            }
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button(action: { showSourceEdit.toggle() }) {
                        Image(systemName: "safari")
                    }
                }
                
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    Button(action: { showSourceSearch.toggle() }) {
                        Image(systemName: "magnifyingglass")
                    }
                }
                
            }
            .navigationTitle("Explore Source")
            .sheet(isPresented: $showSourceEdit) {
                NavigationStack {
                    SourceListScreen()
                }
            }
            .sheet(isPresented: $showSourceSearch) {
                NavigationStack {
                    SearchSourceListScreen()
                }
            }
            .navigationDestination(for: Scraper.self) { scraper in
                ExploreSourceView(scraper: scraper)
            }
        }
    }
}
