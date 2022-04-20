//
//  RootView.swift
//  RootView
//
//  Created by Stephan Deumier on 13/08/2021.
//

import Foundation
import SwiftUI
import MangaScraper

struct RootView: View {
    @EnvironmentObject var readerManager: ReaderManager
    
    enum ActiveTab: String {
        case explore, library, history, settings
    }

    @AppStorage("selectedTab") private var tab: ActiveTab = .library

    var body: some View {
        TabView(selection: $tab) {
            LibraryTabView()
                .tabItem { Label("Library", systemImage: "books.vertical") }
                .tag(ActiveTab.library)
            
            HistoryTabView()
                .tabItem { Label("History", systemImage: "clock") }
                .tag(ActiveTab.history)

            ExploreTabView()
                .tabItem { Label("Explore", systemImage: "safari") }
                .tag(ActiveTab.explore)

            SettingsTabView()
                .tabItem { Label("Settings", systemImage: "gear") }
                .tag(ActiveTab.settings)
        }
        .overlay(alignment: .bottom) { LibraryRefresher() }
        .fullScreenCover(item: $readerManager.selectedChapter) { data in
            ReaderView(vm: .init(manga: data.manga, chapter: data.chapter, scraper: data.scraper))
                .environmentObject(readerManager)
        }
    }
}
