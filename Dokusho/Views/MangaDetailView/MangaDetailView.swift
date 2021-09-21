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
    
    init(mangaId: String, src: Int, showDismiss: Bool = true) {
        self._vm = .init(wrappedValue: .init(for: src, mangaId: mangaId, showDismiss: showDismiss))
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
        ScrollView {
            if vm.error {
                VStack {
                    Text("Something weird happened, try again")
                    AsyncButton(action: { await vm.update() }) {
                        Image(systemName: "arrow.counterclockwise")
                    }
                }
            }
            
            if !vm.error && vm.manga == nil {
                ProgressView()
                    .progressViewStyle(.circular)
                    .frame(maxWidth: .infinity)
            }
            
            if !vm.error && vm.manga != nil {
                MangaDetailHeader(vm: vm)
                    .padding(.bottom)
                MangaDetailInformation(vm: vm)
                    .padding(.top, 5)
                    .padding(.bottom, 15)
                Divider()
                ChapterListInformation(manga: vm.manga!, selectedChapter: $vm.selectedChapter)
                    .padding(.bottom)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                if vm.showDismiss {
                    Button(action: dismiss.callAsFunction) {
                        Image(systemName: "chevron.down")
                    }
                    .buttonStyle(.plain)
                    
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Link(destination: self.vm.getMangaURL()) {
                    Image(systemName: "safari")
                }
            }
        }
        .task(priority: .userInitiated) { await vm.fetchManga() }
        .fullScreenCover(item: $vm.selectedChapter) { chapter in
            ReaderView(vm: .init(for: chapter))
        }
    }
}

