//
//  MangaForSourcePage.swift
//  Dokusho
//
//  Created by Stef on 04/10/2021.
//

import SwiftUI
import MangaScraper
import GRDBQuery

struct MangaForSourcePage: View {
    @Query<DetailedMangaInListRequest> var list: [DetailedMangaInList]
    @State var selectedManga: DetailedMangaInList?
    
    var columns: [GridItem] = [GridItem(.adaptive(minimum: 120, maximum: 120))]
    var scraper: Scraper
    
    init(scraper: Scraper) {
        self.scraper = scraper
        _list = Query(DetailedMangaInListRequest(requestType: .forScraper(scraper: scraper)))
    }
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns) {
                ForEach(list) { data in
                    MangaCardView(manga: data.manga, count: data.unreadChapterCount)
                        .onTapGesture { selectedManga = data }
                }
            }
            .navigationTitle("\(scraper.name) (\(list.count))")
            .navigationBarTitleDisplayMode(.automatic)
            .sheetSizeAware(item: $selectedManga, content: { data in
                MangaDetailView(mangaId: data.manga.mangaId, scraper: data.scraper)
            })
        }
    }
}
