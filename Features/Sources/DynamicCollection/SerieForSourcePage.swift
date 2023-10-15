import SwiftUI
import SerieScraper
import DataKit
import SharedUI
import SerieDetail

public struct SerieForSourcePage: View {
//    @GRDBQuery.Query<DetailedMangaInListRequest> var list: [DetailedMangaInList]
    
    @Bindable var scraper: Scraper

    private var columns: [GridItem] = [GridItem(.adaptive(minimum: 130, maximum: 130))]
    
    public init(scraper: Scraper) {
        self.scraper = scraper
//        _list = Query(DetailedMangaInListRequest(requestType: .scraper(scraper: scraper)))
    }
    
    public var body: some View {
        ScrollView {
//            MangaList(mangas: list) { data in
////                NavigationLink(destination: MangaDetail(mangaId: data.manga.mangaId, scraper: data.scraper)) {
//                    MangaCard(title: data.manga.title, imageUrl: data.manga.cover, chapterCount: data.unreadChapterCount)
//                        .mangaCardFrame()
////                }
//                .buttonStyle(.plain)
//            }
//            .navigationTitle("\(scraper.name) (\(list.count))")
//            .navigationBarTitleDisplayMode(.automatic)
        }
    }
}
