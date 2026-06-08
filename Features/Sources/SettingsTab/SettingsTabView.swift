    //
    //  SettingsView.swift
    //  Dokusho (iOS)
    //
    //  Created by Stephan Deumier on 28/06/2021.
    //

import SwiftUI
import UniformTypeIdentifiers
import Common

public struct SettingsTabView: View {
    @State var vm = SettingsVM()
    @Preference(\.useNewHorizontalReader) var userNewHorizontalReader
    @Preference(\.useNewVerticalReader) var useNewVerticalReader
    @Preference(\.onlyUpdateAllRead) var onlyUpdateAllRead
    @Preference(\.numberOfPreloadedImages) var numberOfPreloadedImages
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            List {
                Section("Sources") {
                    NavigationLink(destination: TsundokuSettingsView()) {
                        Label("Tsundoku", systemImage: "server.rack")
                    }
                }

                Section("Data") {
                    Button(action: { vm.createBackup() }) {
                        Text("Create Backup")
                    }
                    Button(action: { vm.showImportfile.toggle() }) {
                        Text("Import Backup")
                    }
                    Button(action: { vm.cleanOrphanData() }) {
                        Text("Clean orphan data")
                    }
                    Stepper("\(numberOfPreloadedImages) preloaded images", value: $numberOfPreloadedImages, in: 3...6, step: 1)
                }
                
                Section("Experimental") {
                    Toggle("Use new horizontal reader", isOn: $userNewHorizontalReader)
                    Toggle("Use new vertical reader", isOn: $useNewVerticalReader)
                }
                
                Section("Cache") {
                    Button(action: { vm.clearImageCache() }) {
                        Text("Clear image cache")
                    }
                }
                
                Section("Collection Update") {
                    Toggle("Only update when manga has no unread chapter", isOn: $onlyUpdateAllRead)
                }
            }
            .fileExporter(isPresented: $vm.showExportfile, document: vm.file, contentType: .json, defaultFilename: vm.fileName) { res in
                vm.showExportfile.toggle()
            }
            .fileImporter(isPresented: $vm.showImportfile, allowedContentTypes: [.json], allowsMultipleSelection: false) { res in
                let url = try! res.get().first!
                Task { await vm.importBackup(url: url) }
            }
            .overlay {
                if vm.actionInProgress {
                    ZStack {
                        Color.black.opacity(0.25)
                            .ignoresSafeArea()
                        ProgressView()
                            .scaleEffect(2)
                            .padding(40)
                            .glassEffect(in: .rect(cornerRadius: 20))
                    }
                    .zIndex(1000)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}
