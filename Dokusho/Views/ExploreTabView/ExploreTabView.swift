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
    @Environment(\.appDatabase) var appDb
    
    @Query(ScraperRequest(type: .onlyFavorite)) var favoriteScrapers
    @Query(ScraperRequest(type: .onlyActive)) var activeScrapers

    @State var searchText: String = ""
    
    var body: some View {
        NavigationView {
            Group {
                if searchText.isEmpty {  NotSearchingUI }
                else { SearchingUI }
            }
            .toolbar { EditButton() }
            .searchable(text: $searchText)
            .navigationTitle("Explore Source")
        }
    }
    
    func onlyGetThirdPartyScraper() -> [Source] {
        return MangaScraperService.shared.list
            .filter { src in return !activeScrapers.contains(where: { scraper in src.id == scraper.id }) }
            .filter { src in return !favoriteScrapers.contains(where: { scraper in src.id == scraper.id }) }
    }
    
    @ViewBuilder
    var SearchingUI: some View {
        Text("Searching \(searchText)")
    }
    
    @ViewBuilder
    var NotSearchingUI: some View {
        List {
            Section("Favorite") {
                ForEach(favoriteScrapers) { scraper in
                    FavoriteSourceRowView(scraper: scraper)
                        .id(scraper.id)
                }
                .onMove(perform: { onMove(offsets: $0, position: $1) })
            }
            .animation(.easeIn, value: favoriteScrapers)

            Section("Active") {
                ForEach(activeScrapers) { scraper in
                    ActiveSourceRowView(scraper: scraper)
                        .id(scraper.id)
                }
                .onMove(perform: { onMove(offsets: $0, position: $1) })
            }
            .animation(.easeIn, value: activeScrapers)

            Section("All Sources") {
                ForEach(onlyGetThirdPartyScraper(), id: \.id) { source in
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
                Button(action: { toogleActive(source: source) }) {
                    Label("Activate", systemSymbol: .checkmark)
                }.tint(.purple)
            }
    }
    
    @ViewBuilder
    func ActiveSourceRowView(scraper: Scraper) -> some View {
        let source = scraper.asSource()!

        ScraperRow(scraper: scraper)
            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                Button(action: { toogleActive(source: source) }) {
                    Label("Deactivate", systemSymbol: .xmark)
                }.tint(.purple)
            }
            .swipeActions(edge: .leading, allowsFullSwipe: true) {
                Button(action: { toogleFavorite(source: source) }) {
                    Label("Favorite", systemSymbol: .handThumbsup)
                }.tint(.blue)
            }
    }
    
    @ViewBuilder
    func FavoriteSourceRowView(scraper: Scraper) -> some View {
        let source = scraper.asSource()!

        ScraperRow(scraper: scraper)
            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                Button(action: { toogleActive(source: source) }) {
                    Label("Deactivate", systemSymbol: .xmark)
                }.tint(.purple)
            }
            .swipeActions(edge: .leading, allowsFullSwipe: true) {
                Button(action: { toogleFavorite(source: source) }) {
                    Label("Unfavorite", systemSymbol: .handThumbsdown)
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

    func toogleActive(source: Source) {
        do {
            try appDb.database.write { db in
                let scraper = try Scraper.fetchOne(db, id: source.id)
                if var scraper = scraper {
                    scraper.isActive.toggle()
                    try scraper.save(db)
                } else {
                    var scraper = Scraper(from: source)
                    scraper.isActive = true
                    try scraper.save(db)
                }
            }
        } catch(let err) {
            print(err)
        }
    }

    func toogleFavorite(source: Source) {
        do {
            try appDb.database.write { db in
                let scraper = try Scraper.fetchOne(db, id: source.id)
                if var scraper = scraper {
                    scraper.isFavorite.toggle()
                    try scraper.save(db)
                } else {
                    var scraper = Scraper(from: source)
                    scraper.isFavorite = true
                    try scraper.save(db)
                }
            }
        } catch(let err) {
            print(err)
        }
    }
    
    func onMove(offsets: IndexSet, position: Int) {
        do {
            try appDb.database.write { db in
                // Should probably be change as before to only order between section 🤷‍♂️
                var scrapers = try Scraper.all().orderByPosition().fetchAll(db)

                // change the order of the items in the array
                scrapers.move(fromOffsets: offsets, toOffset: position)

                // update the userOrder attribute in revisedItems to
                // persist the new order. This is done in reverse order
                // to minimize changes to the indices.
                for reverseIndex in stride(from: scrapers.count - 1, through: 0, by: -1) {
                    scrapers[reverseIndex].position = reverseIndex
                    try scrapers[reverseIndex].save(db)
                }
            }
        } catch(let err) {
            print(err)
        }
    }
}

struct ExploreTabView_Previews: PreviewProvider {
    static var previews: some View {
        ExploreTabView()
            .environment(\.appDatabase, .uiTest())
    }
}
