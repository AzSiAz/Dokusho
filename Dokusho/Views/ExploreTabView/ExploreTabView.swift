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

struct ExploreTabView: View {
    @StateObject var vm = ExploreTabVM()
    
    @Query(ScraperRequest(type: .onlyFavorite)) var favoriteScrapers
    @Query(ScraperRequest(type: .onlyActive)) var activeScrapers
    
    var body: some View {
        NavigationView {
            Group {
                if vm.searchText.isEmpty {  NotSearchingUI }
                else { SearchingUI }
            }
            .toolbar { EditButton() }
            .searchable(text: $vm.searchText)
            .navigationTitle("Explore Source")
        }
    }
    
    @ViewBuilder
    var SearchingUI: some View {
        Text("Searching \(vm.searchText)")
    }
    
    @ViewBuilder
    var NotSearchingUI: some View {
        List {
            Section("Favorite") {
                ForEach(favoriteScrapers) { scraper in
                    FavoriteSourceRowView(scraper: scraper)
                        .id(scraper.id)
                }
                .onMove(perform: { vm.onMove(scrapers: favoriteScrapers, offsets: $0, position: $1) })
            }
            .animation(.easeIn, value: favoriteScrapers)

            Section("Active") {
                ForEach(activeScrapers) { scraper in
                    ActiveSourceRowView(scraper: scraper)
                        .id(scraper.id)
                }
                .onMove(perform: { vm.onMove(scrapers: activeScrapers, offsets: $0, position: $1) })
            }
            .animation(.easeIn, value: activeScrapers)

            Section("All Sources") {
                ForEach(vm.onlyGetThirdPartyScraper(favorite: favoriteScrapers, active: activeScrapers), id: \.id) { source in
                    OtherSourceRowView(source: source)
                        .id(source.id)
                }
            }
        }
    }
    
    @ViewBuilder
    func OtherSourceRowView(source: Source) -> some View {
        SourceRow(src: source)
            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                Button(action: { vm.toogleActive(source: source) }) {
                    Label("Activate", systemImage: "checkmark")
                }.tint(.purple)
            }
    }
    
    @ViewBuilder
    func ActiveSourceRowView(scraper: Scraper) -> some View {
        let source = scraper.asSource()!

        ScraperRow(scraper: scraper)
            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                Button(action: { vm.toogleActive(source: source) }) {
                    Label("Deactivate", systemImage: "xmark")
                }.tint(.purple)
            }
            .swipeActions(edge: .leading, allowsFullSwipe: true) {
                Button(action: { vm.toogleFavorite(source: source) }) {
                    Label("Favorite", systemImage: "hand.thumbsup")
                }.tint(.blue)
            }
    }
    
    @ViewBuilder
    func FavoriteSourceRowView(scraper: Scraper) -> some View {
        let source = scraper.asSource()!

        ScraperRow(scraper: scraper)
            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                Button(action: { vm.toogleActive(source: source) }) {
                    Label("Deactivate", systemImage: "xmark")
                }.tint(.purple)
            }
            .swipeActions(edge: .leading, allowsFullSwipe: true) {
                Button(action: { vm.toogleFavorite(source: source) }) {
                    Label("Unfavorite", systemImage: "hand.thumbsdown")
                }.tint(.blue)
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
    func ScraperRow(scraper: Scraper) -> some View {
        let src = scraper.asSource()!
        NavigationLink(destination: ExploreSourceView(scraper: scraper)) {
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
    }
}

struct ExploreTabView_Previews: PreviewProvider {
    static var previews: some View {
        ExploreTabView()
            .environment(\.appDatabase, .uiTest())
    }
}
