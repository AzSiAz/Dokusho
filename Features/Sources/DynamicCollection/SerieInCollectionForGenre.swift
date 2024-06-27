import SwiftUI
import DataKit
import SharedUI
import SerieDetail

public struct SerieInCollectionForGenre: View {
    @Query<DetailedSerieInListRequest> var list: [DetailedSerieInList]

    var genre: String
    
    public init(genre: String) {
        self.genre = genre
        _list = Query(DetailedSerieInListRequest(requestType: .genre(genre: genre)))
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
        }
        .navigationTitle("\(genre) (\(list.count))")
        .navigationBarTitleDisplayMode(.automatic)
    }
}
