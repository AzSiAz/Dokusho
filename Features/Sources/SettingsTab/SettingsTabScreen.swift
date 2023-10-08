import Foundation
import SwiftUI
import UniformTypeIdentifiers
import Common
import Backup
import DataKit
import Nuke
import OSLog

public struct SettingsTabScreen: View {
    @Environment(BackupManager.self) private var backupManager
    @Environment(UserPreferences.self) private var userPreference
    
    @State private var showExportfile = false
    @State private var file: Backup?
    @State private var fileName: String?
    @State private var showImportfile = false
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            List {
                @Bindable var userPreferences = userPreference
                Section("Backup") {
                    Button(action: { createBackup() }) {
                        Text("Create Backup")
                    }
                    Button(action: { showImportfile.toggle() }) {
                        Text("Import Backup")
                    }
                }
                
                Section("Reader") {
                    Toggle("Use new horizontal reader", isOn: $userPreferences.useNewHorizontalReader)
                    Toggle("Use new vertical reader", isOn: $userPreferences.useNewVerticalReader)
                    Stepper("Preloaded images: \(userPreference.numberOfPreloadedImages)", value: $userPreferences.numberOfPreloadedImages, in: 3...6, step: 1)
                }
                
                Section("Cache") {
                    Button(action: { clearImageCache() }) {
                        Text("Clear image cache")
                    }
                    Button(action: { cleanOrphanData() }) {
                        Text("Clean manga cache (not in library)")
                    }
                    .disabled(true)
                }
                
                Section("Collections") {
                    Toggle("Only update when manga has no unread chapter", isOn: $userPreferences.onlyUpdateAllRead)
                }
            }
            .fileExporter(isPresented: $showExportfile, document: file, contentType: .json, defaultFilename: fileName) { _ in
                showExportfile.toggle()
                file = nil
            }
            .fileImporter(isPresented: $showImportfile, allowedContentTypes: [.json], allowsMultipleSelection: false) { res in
                guard let url = try! res.get().first else { return }
                Task { await importBackup(url: url) }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

extension SettingsTabScreen {
    func createBackup() {
        let backup = backupManager.createBackup()

        fileName = "dokusho-backup-\(Date.now.ISO8601Format()).json"
        file = Backup(data: backup)

        showExportfile.toggle()
    }
    
    func importBackup(url: URL) async {
        do {
            CFURLStartAccessingSecurityScopedResource(url as CFURL)
//            let data = try Data(contentsOf: url)
//            let backup = try JSONDecoder().decode(BackupData.self, from: data)
            CFURLStopAccessingSecurityScopedResource(url as CFURL)
            throw "TODO: Fix backup"

//            await backupManager.importBackup(backup: backup)
        } catch {
            Logger.backup.error("Error importing backup: \(error.localizedDescription)")
            CFURLStopAccessingSecurityScopedResource(url as CFURL)
        }
    }
    
    func cleanOrphanData() {}
    
    func clearImageCache() {
        Nuke.DataLoader.sharedUrlCache.removeAllCachedResponses()
        Nuke.ImageCache.shared.removeAll()
        DataCache.DiskCover?.removeAll()
    }
}
