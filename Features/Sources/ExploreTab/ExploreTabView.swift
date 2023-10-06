//
//  ContentView.swift
//  Dokusho
//
//  Created by Stephan Deumier on 13/08/2021.
//

import SwiftUI
import MangaScraper
import GRDB
import GRDBQuery
import Combine
import DataKit
import SharedUI

public struct ExploreTabView: View {
    @GRDBQuery.Query(ScraperRequest(type: .onlyFavorite)) var favoriteScrapers
    @GRDBQuery.Query(ScraperRequest(type: .onlyActive)) var activeScrapers

    @State var vm = ExploreTabViewModel()
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            List {
                if favoriteScrapers.count >= 1 {
                    Section("Favorite") {
                        ForEach(favoriteScrapers) { scraper in
                            FavoriteSourceRowView(scraper: scraper)
                                .id(scraper.id)
                        }
                        .onMove(perform: { vm.onMove(scrapers: favoriteScrapers, offsets: $0, position: $1) })
                    }
                }

                if activeScrapers.count >= 1 {
                    Section("Active") {
                        ForEach(activeScrapers) { scraper in
                            ActiveSourceRowView(scraper: scraper)
                                .id(scraper.id)
                        }
                        .onMove(perform: { vm.onMove(scrapers: activeScrapers, offsets: $0, position: $1) })
                    }
                }

                if vm.onlyGetThirdPartyScraper(favorite: favoriteScrapers, active: activeScrapers).count >= 1 {
                    Section("All Sources") {
                        ForEach(vm.onlyGetThirdPartyScraper(favorite: favoriteScrapers, active: activeScrapers), id: \.id) { source in
                            OtherSourceRowView(source: source)
                                .id(source.id)
                        }
                    }
                }
            }
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    EditButton()
                }
                
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    Button(action: { vm.showSourceMangaSearchModal.toggle() }) {
                        Image(systemName: "magnifyingglass")
                    }
                }
                
            }
            .navigationTitle("Explore Source")
        }
        .sheet(isPresented: $vm.showSourceMangaSearchModal) {
            SearchSourceListScreen(scrapers: favoriteScrapers+activeScrapers)
        }
    }
    
    @ViewBuilder
    func OtherSourceRowView(source: Source) -> some View {
        SourceRow(src: source)
            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                Button(action: { vm.toogleActive(source: source) }) {
                    Label("Activate", systemImage: "checkmark")
                }
                .tint(.purple)
            }
    }
    
    @ViewBuilder
    func ActiveSourceRowView(scraper: ScraperDB) -> some View {
        let source = scraper.asSource()!

        ScraperRow(scraper: scraper)
            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                Button(action: { vm.toogleActive(source: source) }) {
                    Label("Deactivate", systemImage: "xmark")
                }
                .tint(.purple)
            }
            .swipeActions(edge: .leading, allowsFullSwipe: true) {
                Button(action: { vm.toogleFavorite(source: source) }) {
                    Label("Favorite", systemImage: "hand.thumbsup")
                }
                .tint(.blue)
            }
    }
    
    @ViewBuilder
    func FavoriteSourceRowView(scraper: ScraperDB) -> some View {
        let source = scraper.asSource()!

        ScraperRow(scraper: scraper)
            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                Button(action: { vm.toogleActive(source: source) }) {
                    Label("Deactivate", systemImage: "xmark")
                }
                .tint(.purple)
            }
            .swipeActions(edge: .leading, allowsFullSwipe: true) {
                Button(action: { vm.toogleFavorite(source: source) }) {
                    Label("Unfavorite", systemImage: "hand.thumbsdown")
                }
                .tint(.blue)
            }
    }
    
    @ViewBuilder
    func SourceRow(src: Source) -> some View {
        HStack {
            RemoteImageCacheView(url: src.icon, contentMode: .fit)
                .frame(width: 32, height: 32)
                .padding(.trailing)
            
            VStack(alignment: .leading) {
                Text(src.name)
                Text(src.lang.rawValue)
            }
            .padding(.leading, 8)
        }
        .padding(.vertical)
    }
    
    @ViewBuilder
    func ScraperRow(scraper: ScraperDB) -> some View {
        if let src = scraper.asSource() {
            NavigationLink(destination: ExploreSourceView(scraper: scraper)) {
                SourceRow(src: src)
            }
        }
    }
}
