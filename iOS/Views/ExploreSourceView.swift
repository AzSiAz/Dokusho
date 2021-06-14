//
//  ExploreDetailView.swift
//  Dokusho (iOS)
//
//  Created by Stephan Deumier on 05/06/2021.
//

import SwiftUI
import NukeUI

struct ExploreSourceView: View {
    @StateObject var vm: ExploreSourceVM
    
    var columns: [GridItem] {
        var base = [
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible()),
        ]
        
        if UIDevice.current.userInterfaceIdiom == .pad || UIDevice.current.userInterfaceIdiom == .mac {
            base = [GridItem(.adaptive(minimum: 180, maximum: 180))]
        }
        
        return base
    }
    
    var body: some View {
        ScrollView {
            if vm.error {
                VStack {
                    Text("Something weird happened, try again")
                    Button(action: {
                        async {
                            await vm.fetchList(clean: true)
                        }
                    }, label: {
                        Image(systemName: "arrow.counterclockwise")
                    })
                }
            }
            
            if !vm.error && vm.mangas.isEmpty {
                ProgressView()
                    .progressViewStyle(.circular)
                    .frame(maxWidth: .infinity)
            }
            
            if !vm.error && !vm.mangas.isEmpty {
                LazyVGrid(columns: columns) {
                    ForEach(vm.mangas) { manga in
                        NavigationLink(destination: MangaDetailView(vm: MangaDetailVM(for: vm.src, mangaId: manga.id))) {
                            ImageWithTextOver(title: manga.title, imageUrl: manga.thumbnailUrl)
                                .frame(height: 180)
                                .task { await vm.fetchMoreIfPossible(for: manga) }
                        }
                    }
                }
                .padding()
            }
        }
        .refreshable { await vm.fetchList(clean: true) }
        .toolbar {
            ToolbarItem(placement: .principal) { Header() }
        }
        .navigationTitle(vm.getTitle())
        .task { await vm.fetchList() }
    }
    
    func Header() -> some View {
        Picker("Order", selection: $vm.type) {
            ForEach(SourceFetchType.allCases) { type in
                Text(type.rawValue).tag(type)
            }
        }
        .pickerStyle(.segmented)
        .onChange(of: vm.type) { _ in
            async {
                await vm.fetchList(clean: true)
            }
        }
        .frame(maxWidth: 150)
    }
}

struct ExploreSourceView_Previews: PreviewProvider {
    static var previews: some View {
        ExploreSourceView(vm: ExploreSourceVM(for: MangaSeeSource()))
    }
}
