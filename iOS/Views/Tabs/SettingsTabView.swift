//
//  SettingsView.swift
//  Dokusho (iOS)
//
//  Created by Stephan Deumier on 28/06/2021.
//

import SwiftUI

struct SettingsTabView: View {
    @StateObject var vm: SettingsVM
    
    var body: some View {
        NavigationView {
            List {
                Section("Backup") {
                    Button(action: { vm.createBackup() }) {
                        Text("Create Backup")
                    }
                    Button(action: { vm.importBackup() }) {
                        Text("Import Backup")
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
        }
        .navigationViewStyle(.stack)
    }
}

struct SettingsTabView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsTabView(vm: .init())
    }
}
