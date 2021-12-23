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

    @State var tab: ActiveTab = .library

    var body: some View {
        TabView(selection: $tab) {
            LibraryTabView()
                .tabItem { Label("Library", systemSymbol: .booksVertical) }
                .tag(ActiveTab.library)
            
            HistoryTabView()
                .tabItem { Label("History", systemSymbol: .clock) }
                .tag(ActiveTab.history)

            ExploreTabView()
                .tabItem { Label("Explore", systemSymbol: .safari) }
                .tag(ActiveTab.explore)

            SettingsTabView()
                .tabItem { Label("Settings", systemSymbol: .gear) }
                .tag(ActiveTab.settings)
        }
    }
}
