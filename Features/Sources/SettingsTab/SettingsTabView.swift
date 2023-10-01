import Foundation
import SwiftUI
import UniformTypeIdentifiers
import Common
import Backup
import DataKit
import GRDBQuery
import GRDB

public struct SettingsTabView: View {
    @Environment(BackupManager.self) private var backupManager
    @Environment(UserPreferences.self) private var userPreference
    
    @State private var vm = SettingsViewModel()
    
    public init() {}
    
    public var body: some View {
        NavigationView {
            @Bindable var userPreferences = userPreference
            List {
                Section("Data") {
                    Button(action: { vm.createBackup(manager: backupManager) }) {
                        Text("Create Backup")
                    }
                    Button(action: { vm.showImportfile.toggle() }) {
                        Text("Import Backup")
                    }
                    Button(action: { vm.cleanOrphanData() }) {
                        Text("Clean orphan data")
                    }
                    Stepper("\(userPreference.numberOfPreloadedImages) preloaded images", value: $userPreferences.numberOfPreloadedImages, in: 3...6, step: 1)
                }
                
                Section("Experimental") {
                    Toggle("Use new horizontal reader", isOn: $userPreferences.useNewHorizontalReader)
                    Toggle("Use new vertical reader", isOn: $userPreferences.useNewVerticalReader)
                }
                
                Section("Cache") {
                    Button(action: { vm.clearImageCache() }) {
                        Text("Clear image cache")
                    }
                }
                
                Section("Collection Update") {
                    Toggle("Only update when manga has no unread chapter", isOn: $userPreferences.onlyUpdateAllRead)
                }
            }
            .fileExporter(isPresented: $vm.showExportfile, document: vm.file, contentType: .json, defaultFilename: vm.fileName) { res in
                vm.showExportfile.toggle()
            }
            .fileImporter(isPresented: $vm.showImportfile, allowedContentTypes: [.json], allowsMultipleSelection: false) { res in
                let url = try! res.get().first!
                Task { await vm.importBackup(url: url, manager: backupManager) }
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
