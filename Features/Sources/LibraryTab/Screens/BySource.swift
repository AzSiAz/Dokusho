//
//  BySourceListPage.swift
//  Dokusho
//
//  Created by Stef on 04/10/2021.
//

import SwiftUI
import MangaScraper
import GRDBQuery
import DataKit
import DynamicCollection

public struct BySourceListPage: View {
//    @GRDBQuery.Query(ScraperWithMangaInCollection()) var scrapers
    
    public init() {}
    
    public var body: some View {
//        List {
//            ForEach(scrapers) { scraper in
//                NavigationLink(destination: MangaForSourcePage(scraper: scraper.scraper)) {
//                    Text(scraper.scraper.name)
//                        .badge(scraper.mangaCount)
//                }
//            }
//        }
//        .navigationBarTitleDisplayMode(.inline)
//        .navigationTitle("By Sources")
        EmptyView()
    }
}
