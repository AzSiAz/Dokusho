//
//  BySourceListPage.swift
//  Dokusho
//
//  Created by Stef on 04/10/2021.
//

import SwiftUI
import MangaScraper
import GRDBQuery

struct BySourceListPage: View {
    @Query(ScraperWithMangaInCollection()) var scrapers
    
    var body: some View {
        List {
            ForEach(scrapers) { scraper in
                NavigationLink(destination: MangaForSourcePage(scraper: scraper.scraper)) {
                    Text(scraper.scraper.name)
                        .badge(scraper.mangaCount)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("By Sources")
    }
}
