import SwiftUI
import SerieScraper
import DataKit
import SharedUI
import SerieDetail

public struct SerieForScraperPage: View {
    @Query<DetailedSerieInListRequest> var list: [DetailedSerieInList]
    
    var scraper: Scraper

    private var columns: [GridItem] = [GridItem(.adaptive(minimum: 130, maximum: 130))]
    
    public init(scraper: Scraper) {
        self.scraper = scraper
        _list = Query(DetailedSerieInListRequest(requestType: .scraper(scraper: scraper)))
    }
    
    public var body: some View {
        ScrollView {
            SerieList(series: list) { data in
                NavigationLink(destination: SerieDetailScreen(serieInternalID: data.serie.internalID, scraperID: data.scraper.id)) {
                    SerieCard(title: data.serie.title, imageUrl: data.serie.cover, chapterCount: data.unreadChapterCount)
                        .serieCardFrame()
                }
                .buttonStyle(.plain)
            }
            .navigationTitle("\(scraper.name) (\(list.count))")
            .navigationBarTitleDisplayMode(.automatic)
        }
    }
}
