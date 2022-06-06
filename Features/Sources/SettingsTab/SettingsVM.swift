//
//  SettingsVM.swift
//  Dokusho (iOS)
//
//  Created by Stephan Deumier on 28/06/2021.
//

import Foundation
import SwiftUI
import Nuke
import DataKit
import Backup

class SettingsVM: ObservableObject {
    @Published var actionInProgress = false
    @Published var showExportfile = false
    @Published var file: Backup?
    @Published var fileName: String?
    @Published var showImportfile = false
    
    @MainActor
    func createBackup() {
        actionInProgress.toggle()
        
        let backup = BackupManager.shared.createBackup()

        fileName = "dokusho-backup-\(Date.now.ISO8601Format()).json"
        file = Backup(data: backup)

        showExportfile.toggle()
        actionInProgress.toggle()
    }
    
    @MainActor
    func importBackup(url: URL) async {
        do {
            CFURLStartAccessingSecurityScopedResource(url as CFURL)
            actionInProgress.toggle()
            let data = try Data(contentsOf: url)
            let backup = try JSONDecoder().decode(BackupData.self, from: data)
            CFURLStopAccessingSecurityScopedResource(url as CFURL)

            await BackupManager.shared.importBackup(backup: backup)

            self.actionInProgress.toggle()
        } catch {
            print(error)
            self.actionInProgress.toggle()
        }
    }
    
    @MainActor
    func cleanOrphanData() {}
    
    func clearImageCache() {
        Nuke.DataLoader.sharedUrlCache.removeAllCachedResponses()
        Nuke.ImageCache.shared.removeAll()
        DataCache.DiskCover?.removeAll()
    }
}
