//
//  RootView.swift
//  RootView
//
//  Created by Stephan Deumier on 13/08/2021.
//

import Foundation
import SwiftUI
import MangaScraper
import SettingsTab
import HistoryTab
import Backup
import LibraryTab
import ExploreTab
import Common
import DataKit
import SwiftData

struct RootView: View {
    @Environment(BackupManager.self) var backupManager

    @AppStorage("selectedTab") private var tab: ActiveTab = .library
    
    var body: some View {
        if backupManager.isImporting { BackupImporterScreen() }
        else if UIScreen.isLargeScreen { iPadView }
        else { iPhoneView }
    }

    @ViewBuilder
    var iPhoneView: some View {
        TabView(selection: $tab) {
//            libraryTab
//            historyTab
            exploreTab
            settingTab
        }
    }
    
    // TODO: Change to double sidebar to avoid using a not ergonomic tab bar for iPadOS & MacOS
    @ViewBuilder
    var iPadView: some View {
        iPhoneView
    }
    
    @ViewBuilder
    var libraryTab: some View {
        LibraryTabView()
            .tabItem { Label("Library", systemImage: "books.vertical") }
            .tag(ActiveTab.library)
    }
    
    @ViewBuilder
    var historyTab: some View {
        HistoryTabView()
            .tabItem { Label("History", systemImage: "clock") }
            .tag(ActiveTab.history)
    }
    
    @ViewBuilder
    var exploreTab: some View {
        ExploreTabView()
            .tabItem { Label("Explore", systemImage: "safari") }
            .tag(ActiveTab.explore)
    }

    @ViewBuilder
    var settingTab: some View {
        SettingsTabScreen()
            .tabItem { Label("Settings", systemImage: "gear") }
            .tag(ActiveTab.settings)
    }
}
