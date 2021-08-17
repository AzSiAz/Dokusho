//
//  DokushoApp.swift
//  Dokusho
//
//  Created by Stephan Deumier on 17/08/2021.
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
