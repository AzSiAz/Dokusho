//
//  ContentView.swift
//  Dokusho
//
//  Created by Stephan Deumier on 13/08/2021.
//

import SwiftUI
import MangaScraper
import Combine
import DataKit
import SharedUI

public struct ExploreTabView: View {
    @Environment(\.modelContext) var context
    @Environment(ScraperService.self) var scrapersService

    @Query(.activeScrapersByPosition()) var scrapers: [Scraper]

    @State var showSourceEdit: Bool = false
    @State var showSourceSearch: Bool = false
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            List {
                ForEach(scrapers) { scraper in
                    NavigationLink(value: scraper) {
                        ScraperRow(scraper: scraper)
                    }
                }
                .onMove(perform: { scrapersService.onMove(offsets: $0, position: $1, in: context) })
            }
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button(action: { showSourceEdit.toggle() }) {
                        Image(systemName: "safari")
                    }
                }
                
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    Button(action: { showSourceSearch.toggle() }) {
                        Image(systemName: "magnifyingglass")
                    }
                }
                
            }
            .navigationTitle("Explore Source")
            .sheet(isPresented: $showSourceEdit) {
                NavigationStack {
                    SourceListScreen()
                }
            }
            .sheet(isPresented: $showSourceSearch) {
                NavigationStack {
                    SearchSourceListScreen()
                }
            }
            .navigationDestination(for: Scraper.self) { scraper in
                ExploreSourceView(scraper: Bindable(scraper))
            }
        }
    }
}
