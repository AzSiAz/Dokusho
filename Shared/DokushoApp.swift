//
//  DokushoApp.swift
//  Shared
//
//  Created by Stephan Deumier on 30/05/2021.
//

import SwiftUI


@main
struct DokushoApp: App {
    var persistenceController = PersistenceController.shared
    
    var body: some Scene {
        WindowGroup {
            Group {
                #if os(iOS)
                RootView()
                #endif
                
                #if os(macOS)
                NavigationView {
                    Text("TODO")
                }
                #endif
            }
            .environment(\.managedObjectContext, persistenceController.container.viewContext)
            .environmentObject(MangaSourceService.shared)
        }
    }
}
