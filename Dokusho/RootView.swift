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
    @Environment(\.modelContext) var modelContext
    @Environment(BackupManager.self) var backupManager

    @AppStorage("selectedTab") private var tab: ActiveTab = .library

    var body: some View {
        if backupManager.isImporting { BackupImporter() }
        else if UIScreen.isLargeScreen { iPadView() }
        else { iPhoneView() }
    }

    @ViewBuilder
    func iPhoneView() -> some View {
        TabView(selection: $tab) {
//            LibraryTabView()
//                .tabItem { Label("Library", systemImage: "books.vertical") }
//                .tag(ActiveTab.library)
//            
//            HistoryTabView()
//                .tabItem { Label("History", systemImage: "clock") }
//                .tag(ActiveTab.history)
//
//            ExploreTabView()
//                .tabItem { Label("Explore", systemImage: "safari") }
//                .tag(ActiveTab.explore)

            SettingsTabView()
                .tabItem { Label("Settings", systemImage: "gear") }
                .tag(ActiveTab.settings)
        }
    }
    
    // TODO: Change to double sidebar to avoid using a not ergonomic tab bar for iPadOS & MacOS
    @ViewBuilder
    func iPadView() -> some View {
        iPhoneView()
    }
}
