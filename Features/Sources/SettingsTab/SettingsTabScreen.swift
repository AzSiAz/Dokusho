import Foundation
import SwiftUI
import Common
import Backup
import DataKit
import Nuke

public struct SettingsTabScreen: View {
    @Environment(UserPreferences.self) private var userPreference
    
    @State private var showImageCleanupAlert = false
    @State private var showDataCleanupAlert = false
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            List {
                @Bindable var userPreferences = userPreference

                Section("Backup") {
                    NavigationLink(destination: BackupChoiceScreen()) {
                        Text("Backup")
                    }
                }

                Section("Reader") {
                    Toggle("Use new horizontal reader", isOn: $userPreferences.useNewHorizontalReader)
                    Toggle("Use new vertical reader", isOn: $userPreferences.useNewVerticalReader)
                    Stepper("Preloaded images: \(userPreference.numberOfPreloadedImages)", value: $userPreferences.numberOfPreloadedImages, in: 3...6, step: 1)
                }
                
                Section("Serie Detail") {
                    Toggle("Show external chapter", isOn: $userPreferences.showExternalChapters)
                }
                
                Section("Cache") {
                    Button(action: { showImageCleanupAlert.toggle() }) {
                        Text("Clear image cache")
                    }

                    Button(action: { showDataCleanupAlert.toggle() }) {
                        Text("Clean serie cache (not in library)")
                    }
                }
                
                Section("Collections") {
                    Toggle("Only update when serie has no unread chapter", isOn: $userPreferences.onlyUpdateAllRead)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .alert("Are you sure you want to clean local image cache ?", isPresented: $showImageCleanupAlert) {
                Button("Yes", role: .destructive) { clearImageCache() }
                Button("Cancel", role: .cancel) { showImageCleanupAlert.toggle() }
            }
            .alert("Are you sure you want to clean local data cache ?", isPresented: $showDataCleanupAlert) {
                Button("Yes", role: .destructive) { cleanOrphanData() }
                Button("Cancel", role: .cancel) { showDataCleanupAlert.toggle() }
            }
        }
    }
}

extension SettingsTabScreen {
    func cleanOrphanData() {
        showDataCleanupAlert.toggle()
    }
    
    func clearImageCache() {
        Nuke.DataLoader.sharedUrlCache.removeAllCachedResponses()
        Nuke.ImageCache.shared.removeAll()
        DataCache.DiskCover?.removeAll()
        
        showImageCleanupAlert.toggle()
    }
}
