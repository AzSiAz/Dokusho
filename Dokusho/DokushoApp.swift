//
//  DokushoApp.swift
//  Dokusho
//
//  Created by Stephan Deumier on 17/08/2021.
//

import SwiftUI
import DataKit
import Backup
import Common

@main
struct DokushoApp: App {
    @State private var userPreferences = UserPreferences.shared
    @State private var backupManager = BackupManager.shared
    @State private var libraryUpdater = LibraryUpdater.shared
    @State private var scraperService = ScraperService.shared

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(\.appDatabase, .shared)
                .environment(libraryUpdater)
                .environment(backupManager)
                .environment(userPreferences)
                .environment(scraperService)
                .dokushoModelContainer()
        }
    }
}
