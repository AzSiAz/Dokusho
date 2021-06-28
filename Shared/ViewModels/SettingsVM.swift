//
//  SettingsVM.swift
//  Dokusho (iOS)
//
//  Created by Stephan Deumier on 28/06/2021.
//

import Foundation
import SwiftUI

class SettingsVM: ObservableObject {
    @Published var libState: LibraryState
    
    init(libState: LibraryState) {
        self.libState = libState
    }
    
    func createBackup() {
        libState.reloadCollection()
        
//        libState.collections
    }
    
    func importBackup() {}
}
