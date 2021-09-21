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
    @State var selectedChapter: ChapterEntity?
    
    init(mangaId: String, src: Int) {
        self._vm = .init(wrappedValue: .init(for: src, mangaId: mangaId))
    }
    
    var body: some View {
        NavigationView {
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
                    ChapterListInformation(manga: vm.manga!, selectedChapter: $selectedChapter)
                        .padding(.bottom)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: dismiss.callAsFunction) {
                        Image(systemName: "chevron.down")
                    }
                    .buttonStyle(.plain)
                    
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Link(destination: self.vm.getMangaURL()) {
                        Image(systemName: "safari")
                    }
                }
            }
            .task(priority: .userInitiated) { await vm.fetchManga() }
            .fullScreenCover(item: $selectedChapter) { chapter in
                ReaderView(vm: .init(for: chapter))
            }
        }
    }
}

