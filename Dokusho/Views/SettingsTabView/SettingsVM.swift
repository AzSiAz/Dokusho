//
//  SettingsVM.swift
//  Dokusho (iOS)
//
//  Created by Stephan Deumier on 28/06/2021.
//

import Foundation
import SwiftUI
import CoreData
import UniformTypeIdentifiers
import Nuke

struct Backup: FileDocument {
    static var readableContentTypes = [UTType.json]
    static var writableContentTypes = [UTType.json]
    
    var data: [CollectionBackup]
    
    init(configuration: ReadConfiguration) throws {
        data = []
    }
    
    
    init(data: [CollectionBackup]) {
        self.data = data
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let data = try! JSONEncoder().encode(data)

        return FileWrapper(regularFileWithContents: data)
    }
}

@MainActor
class SettingsVM: ObservableObject {
    @Published var actionInProgress = false
    @Published var showExportfile = false
    @Published var file: Backup?
    @Published var fileName: String?
    @Published var showImportfile = false
    
    func createBackup(ctx: NSManagedObjectContext) {
        actionInProgress.toggle()
        
        let backup = PersistenceController.shared.createBackup()

        fileName = "dokusho-backup-\(Date.now.ISO8601Format()).json"
        file = Backup(data: backup)

        showExportfile.toggle()
        actionInProgress.toggle()
    }
    
    func importBackup(url: URL, ctx: NSManagedObjectContext) async {
        do {
            CFURLStartAccessingSecurityScopedResource(url as CFURL)
            actionInProgress.toggle()
            let data = try Data(contentsOf: url)
            let backup = try JSONDecoder().decode([CollectionBackup].self, from: data)
            CFURLStopAccessingSecurityScopedResource(url as CFURL)

            await PersistenceController.shared.importBackup(backup: backup)

            self.actionInProgress.toggle()
        } catch {
            print(error)
            self.actionInProgress.toggle()
        }
    }
    
    func cleanOrphanData(ctx: NSManagedObjectContext) {}
    
    func clearImageCache() {
        Nuke.DataLoader.sharedUrlCache.removeAllCachedResponses()
        Nuke.ImageCache.shared.removeAll()
    }
}
