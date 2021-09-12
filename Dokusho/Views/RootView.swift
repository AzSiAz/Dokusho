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
    enum ActiveTab {
        case explore, library, history, settings
    }
    
    @State var tab: ActiveTab = .explore
    
    var body: some View {
        TabView {
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
        .task(priority: .high) {
            await SourceEntity.importAtAppStart(sources: MangaScraperService.shared.list)
        }
    }
}
