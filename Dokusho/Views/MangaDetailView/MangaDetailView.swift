//
//  MangaDetailView.swift
//  Dokusho
//
//  Created by Stephan Deumier on 06/06/2021.
//

import SwiftUI

struct MangaDetailView: View {
    @Environment(\.dismiss) var dismiss

    @StateObject var vm: MangaDetailVM
    
    init(mangaId: String, scraper: Scraper, showDismiss: Bool = true) {
        _vm = .init(wrappedValue: .init(for: scraper, mangaId: mangaId, showDismiss: showDismiss))
    }
    
    var body: some View {
        if vm.showDismiss {
            NavigationView {
                Content()
            }
        }
        else {
            Content()
        }
    }
    
    @ViewBuilder
    func Content() -> some View {
        Group {
            if vm.error {
                VStack {
                    Text("Something weird happened, try again")
                    AsyncButton(action: { await vm.update() }) {
                        Image(systemSymbol: .arrowClockwise)
                    }
                }
            }

            if vm.data != nil { MangaDetail(vm: vm) }
            else {
                ProgressView()
                    .progressViewStyle(.circular)
                    .frame(maxWidth: .infinity)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                if vm.showDismiss {
                    Button(action: dismiss.callAsFunction) {
                        Image(systemSymbol: .chevronDown)
                    }
                    .buttonStyle(.plain)

                }
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                Link(destination: self.vm.getMangaURL()) {
                    Image(systemSymbol: .safari)
                }
            }
        }
        .task(priority: .userInitiated) { await vm.fetchManga() }
    }
}
