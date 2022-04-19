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
    @EnvironmentObject var libraryUpdater: LibraryUpdater
    
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
        .overlay(alignment: .bottom) {
            if let refresh = libraryUpdater.refreshStatus {
                VStack {
                    Text(refresh.refreshTitle)
                        .lineLimit(1)
                        .padding(.horizontal, 10)
                        .padding(.top, 15)
                    ProgressView(value: Double(refresh.refreshProgress), total: Double(refresh.refreshCount))
                        .padding(.horizontal, 10)
                        .padding(.bottom, 2)
                }
                .background(.ultraThickMaterial)
                .clipShape(Rectangle())
                .cornerRadius(15)
                .padding(.horizontal, 50)
                .padding(.bottom, 55)
                .shadow(radius: 5)
            }
        }
    }
}
