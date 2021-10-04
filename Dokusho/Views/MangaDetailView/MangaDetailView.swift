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
    
    init(mangaId: String, src: UUID, showDismiss: Bool = true, isInCollectionPage: Bool = false) {
        self._vm = .init(wrappedValue: .init(for: src, mangaId: mangaId, showDismiss: showDismiss, isInCollectionPage: isInCollectionPage))
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
                MangaDetail(
                    manga: vm.manga!,
                    selectedChapter: $vm.selectedChapter,
                    isInCollectionPage: vm.isInCollectionPage,
                    forceCompact: !vm.showDismiss,
                    update: vm.update,
                    resetCache: vm.resetCache,
                    insertMangaInCollection: vm.insertMangaInCollection,
                    removeMangaFromCollection: vm.removeMangaFromCollection
                )
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
