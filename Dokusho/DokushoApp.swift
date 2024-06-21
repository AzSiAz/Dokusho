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
    @State private var backupManager = BackupManager()
    @State private var libraryUpdater = LibraryUpdater()
    @State private var scraperService = ScraperService.shared
    @State private var serieService = SerieService()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(libraryUpdater)
                .environment(backupManager)
                .environment(userPreferences)
                .environment(scraperService)
                .environment(serieService)
        }
        .modelContainer(.dokusho())
    }
}
