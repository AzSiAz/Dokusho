import SwiftUI

public struct BackupImporterScreen: View {
    @Environment(BackupManager.self) var backupManager
    
    public init() {}
    
    public var body: some View {
        ProgressView("Importing backup", value: backupManager.progress, total: backupManager.total)
            .padding()
    }
}
