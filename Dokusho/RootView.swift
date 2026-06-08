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

struct RootView: View {
    @Environment(BackupManager.self) var backupManager
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @AppStorage("selectedTab") private var tab: ActiveTab = .library

    var body: some View {
        if backupManager.isImporting {
            BackupImporter(backupManager: backupManager)
        } else if horizontalSizeClass == .regular {
            // iPad / regular width: a single unified sidebar.
            IPadRootView()
        } else {
            // iPhone / compact width: the tab bar.
            tabs
        }
    }

    private var tabs: some View {
        TabView(selection: $tab) {
            Tab("Library", systemImage: "books.vertical", value: ActiveTab.library) {
                LibraryRootView()
            }

            Tab("History", systemImage: "clock", value: ActiveTab.history) {
                HistoryTabView()
            }

            Tab("Explore", systemImage: "safari", value: ActiveTab.explore) {
                ExploreTabView()
            }

            Tab("Settings", systemImage: "gear", value: ActiveTab.settings) {
                SettingsTabView()
            }
        }
        .tabBarMinimizeBehavior(.onScrollDown)
    }
}
