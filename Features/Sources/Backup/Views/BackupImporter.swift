//
//  SwiftUIView.swift
//  
//
//  Created by Stef on 05/06/2022.
//

import SwiftUI

public struct BackupImporter: View {
    @ObservedObject var backupManager: BackupManager
    
    public init(backupManager: BackupManager) {
        _backupManager = .init(wrappedValue: backupManager)
    }
    
    public var body: some View {
        ProgressView("Importing backup", value: backupManager.progress, total: backupManager.total)
            .padding()
    }
}

struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        BackupImporter(backupManager: .shared)
    }
}
