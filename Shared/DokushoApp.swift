//
//  DokushoApp.swift
//  Shared
//
//  Created by Stephan Deumier on 30/05/2021.
//

import SwiftUI

@main
struct DokushoApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
