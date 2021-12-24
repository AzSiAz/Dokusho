//
//  DokushoApp.swift
//  Dokusho
//
//  Created by Stephan Deumier on 17/08/2021.
//

import SwiftUI

@main
struct DokushoApp: App {
    var body: some Scene {
        WindowGroup {
            RootView().environment(\.appDatabase, .shared)
        }
    }
}
