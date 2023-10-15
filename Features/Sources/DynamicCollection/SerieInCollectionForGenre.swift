import SwiftUI
import GRDBQuery
import DataKit
import SharedUI
import MangaDetail

public struct SerieInCollectionForGenre: View {
//    @GRDBQuery.Query<DetailedMangaInListRequest> var list: [DetailedMangaInList]

//    @State var selectedManga: DetailedMangaInList?

    var genre: String
    
    public init(genre: String) {
        self.genre = genre
//        _list = Query(DetailedMangaInListRequest(requestType: .genre(genre: genre)))
    }
    
    public var body: some View {
        ScrollView {
//            MangaList(mangas: list) { data in
//                NavigationLink(destination: MangaDetail(mangaId: data.manga.mangaId, scraper: data.scraper)) {
//                    MangaCard(title: data.manga.title, imageUrl: data.manga.cover, chapterCount: data.unreadChapterCount)
//                        .mangaCardFrame()
////                }
//                .buttonStyle(.plain)
//            }
        }
//        .navigationTitle("\(genre) (\(list.count))")
        .navigationBarTitleDisplayMode(.automatic)
    }
}
