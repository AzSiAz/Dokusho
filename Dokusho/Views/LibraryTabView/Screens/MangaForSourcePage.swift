//
//  MangaForSourcePage.swift
//  Dokusho
//
//  Created by Stef on 04/10/2021.
//

import SwiftUI
import MangaScraper
import GRDBQuery
import DataKit
import SharedUI

struct MangaForSourcePage: View {
    @Query<DetailedMangaInListRequest> var list: [DetailedMangaInList]
    
    var scraper: Scraper
    var columns: [GridItem] = [GridItem(.adaptive(minimum: 130, maximum: 130))]
    
    init(scraper: Scraper) {
        self.scraper = scraper
        _list = Query(DetailedMangaInListRequest(scraper: scraper))
    }
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns) {
                ForEach(list) { data in
                    NavigationLink(destination: MangaDetailView(mangaId: data.manga.mangaId, scraper: data.scraper)) {
                        MangaCard(title: data.manga.title, imageUrl: data.manga.cover.absoluteString, chapterCount: data.unreadChapterCount)
                            .mangaCardFrame()
                    }
                    .buttonStyle(.plain)
                }
            }
            .navigationTitle("\(scraper.name) (\(list.count))")
            .navigationBarTitleDisplayMode(.automatic)
        }
    }
}
