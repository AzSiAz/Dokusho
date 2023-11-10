import SwiftUI
import DataKit
import DynamicCollection

public struct SeriesByScraperListPage: View {
    @Query(ScraperWithSerieInCollectionRequest()) var scrapers
    
    public init() {}
    
    public var body: some View {
        List {
            ForEach(scrapers) { scraper in
                NavigationLink(destination: SerieForScraperPage(scraper: scraper.scraper)) {
                    Text(scraper.scraper.name)
                        .badge(scraper.serieCount)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("By Sources")
    }
}
