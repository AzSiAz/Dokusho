import Foundation
import SwiftUI
import Harmony
import OSLog
import UniformTypeIdentifiers
import DataKit

public struct BackupChoiceScreen: View {
    @Environment(BackupManager.self) private var backupManager
    @Environment(ScraperService.self) private var scraperService
    
    @Harmony var harmony
    
    @State private var showExportfile = false
    @State private var file: BackupV2?
    @State private var fileName: String?
    @State private var showImportV1File = false
    @State private var showImportV2File = false
    
    public init() {}
    
    public var body: some View {
        List {
            Section("V1") {
                Button(action: { showImportV1File.toggle() }) {
                    Text("Import")
                }
                .fileImporter(isPresented: $showImportV1File, allowedContentTypes: [.json], allowsMultipleSelection: false) { res in
                    guard let url = try! res.get().first else { return }
                    Task { await importV1Backup(url: url) }
                }
            }
            
            Section("V2") {
                Button(action: { createBackup() }) {
                    Text("Create")
                }
                .fileExporter(isPresented: $showExportfile, document: file, contentType: .json, defaultFilename: fileName) { _ in
                    showExportfile.toggle()
                    file = nil
                }

                Button(action: { showImportV2File.toggle() }) {
                    Text("Import")
                }
                .fileImporter(isPresented: $showImportV2File, allowedContentTypes: [.json], allowsMultipleSelection: false) { res in
                    guard let url = try! res.get().first else { return }
                    Task { await importV1Backup(url: url) }
                }
            }
        }
        .navigationTitle("Backup")
    }
    
    func createBackup() {
        let backup = backupManager.createBackup(harmonic: harmony)
        
        fileName = "dokusho-backup-\(Date.now.ISO8601Format()).json"
        file = BackupV2(data: backup)
        
        showExportfile.toggle()
    }
    
    func importV1Backup(url: URL) async {
        do {
            CFURLStartAccessingSecurityScopedResource(url as CFURL)
            let data = try Data(contentsOf: url)
            let backup = try JSONDecoder().decode(BackupV1.BackupData.self, from: data)
            CFURLStopAccessingSecurityScopedResource(url as CFURL)
            
            try await backupManager.importV1Backup(backup: backup, harmonic: harmony, scraperService: scraperService)
        } catch {
            print(error)
            Logger.backup.error("Error importing backup: \(error.localizedDescription)")
            CFURLStopAccessingSecurityScopedResource(url as CFURL)
        }
    }
    
    func importV2Backup(url: URL) async {
        do {
            CFURLStartAccessingSecurityScopedResource(url as CFURL)
            let data = try Data(contentsOf: url)
            let backup = try JSONDecoder().decode(BackupV2.BackupData.self, from: data)
            CFURLStopAccessingSecurityScopedResource(url as CFURL)
            
            try await backupManager.importV2Backup(backup: backup, harmonic: harmony)
        } catch {
            Logger.backup.error("Error importing backup: \(error.localizedDescription)")
            CFURLStopAccessingSecurityScopedResource(url as CFURL)
        }
    }
}
