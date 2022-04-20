//
//  DokushoApp.swift
//  Dokusho
//
//  Created by Stephan Deumier on 17/08/2021.
//

import SwiftUI
import TelemetryClient
import Inject

@main
struct DokushoApp: App {
    
    @ObservedObject private var iO = Inject.observer
    
    init() {
        TelemetryManager.initialize(with: TelemetryManagerConfiguration.init(appID: "B004B7C1-9A6A-42BF-8234-1B21FC94C6DF"))
    }
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(\.appDatabase, .shared)
                .environmentObject(LibraryUpdater())
                .environmentObject(ReaderManager())
                .enableInjection()
        }
    }
}
