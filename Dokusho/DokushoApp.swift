//
//  DokushoApp.swift
//  Dokusho
//
//  Created by Stephan Deumier on 17/08/2021.
//

import SwiftUI
//import TelemetryClient
import DataKit
import Backup

@main
struct DokushoApp: App {
    @StateObject var libraryUpdater = LibraryUpdater.shared
    @StateObject var backupManager = BackupManager.shared
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(\.appDatabase, .shared)
                .environmentObject(libraryUpdater)
                .environmentObject(backupManager)
        }
    }
}
