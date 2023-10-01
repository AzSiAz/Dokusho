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

@Observable
class SettingsViewModel {
    var actionInProgress = false
    var showExportfile = false
    var file: Backup?
    var fileName: String?
    var showImportfile = false
    
    @MainActor
    func createBackup(manager: BackupManager) {
        actionInProgress.toggle()
        
        let backup = manager.createBackup()

        fileName = "dokusho-backup-\(Date.now.ISO8601Format()).json"
        file = Backup(data: backup)

        showExportfile.toggle()
        actionInProgress.toggle()
    }
    
    @MainActor
    func importBackup(url: URL, manager: BackupManager) async {
        do {
            CFURLStartAccessingSecurityScopedResource(url as CFURL)
            actionInProgress.toggle()
            let data = try Data(contentsOf: url)
            let backup = try JSONDecoder().decode(BackupData.self, from: data)
            CFURLStopAccessingSecurityScopedResource(url as CFURL)

            await manager.importBackup(backup: backup)

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
