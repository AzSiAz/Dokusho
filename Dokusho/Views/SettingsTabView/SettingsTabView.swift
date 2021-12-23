    //
    //  SettingsView.swift
    //  Dokusho (iOS)
    //
    //  Created by Stephan Deumier on 28/06/2021.
    //

import SwiftUI
import UniformTypeIdentifiers

struct SettingsTabView: View {
    @StateObject var vm: SettingsVM = .init()
    
    var body: some View {
        NavigationView {
            List {
                Section("Data") {
                    Button(action: { vm.createBackup() }) {
                        Text("Create Backup")
                    }
                    Button(action: { vm.showImportfile.toggle() }) {
                        Text("Import Backup")
                    }
                    Button(action: { vm.cleanOrphanData() }) {
                        Text("Clean orphan data")
                    }
                }
                
                Section("Cache") {
                    Button(action: { vm.clearImageCache() }) {
                        Text("Clear image cache")
                    }
                }
            }
            .fileExporter(isPresented: $vm.showExportfile, document: vm.file, contentType: .json, defaultFilename: vm.fileName) { res in
                vm.showExportfile.toggle()
            }
            .fileImporter(isPresented: $vm.showImportfile, allowedContentTypes: [.json], allowsMultipleSelection: false) { res in
                let url = try! res.get().first!
                Task { await vm.importBackup(url: url) }
            }
            .overlay {
                if vm.actionInProgress {
                    ZStack {
                        ProgressView()
                            .scaleEffect(2)
                    }
                    .zIndex(1000)
                    .ignoresSafeArea(.all)
                    .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                    .background(.ultraThinMaterial)
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
