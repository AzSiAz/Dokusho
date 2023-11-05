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
    @State private var serieService = SerieService.shared

    @Harmony(
        records: [Scraper.self, SerieCollection.self, Serie.self, SerieChapter.self],
        configuration: Configuration(sharedAppGroupContainerIdentifier: "group.tech.azsias.Dokusho"),
        migrator: .dokushoMigration
    ) var harmony

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(libraryUpdater)
                .environment(backupManager)
                .environment(userPreferences)
                .environment(scraperService)
                .environment(serieService)
                .environment(\.dbQueue, harmony.reader)
        }
    }
}
