//
//  ExploreDetailView.swift
//  Dokusho (iOS)
//
//  Created by Stephan Deumier on 05/06/2021.
//

import SwiftUI
import NukeUI

struct ExploreSourceView: View {
    var dataManager = DataManager.shared
    
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
                    }) {
                        Image(systemName: "arrow.counterclockwise")
                    }
                }
            }
            
            if !vm.error && vm.mangas.isEmpty {
                ProgressView()
                    .progressViewStyle(.circular)
                    .frame(maxWidth: .infinity)
            }
            
            if !vm.error && !vm.mangas.isEmpty {
                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach($vm.mangas) { manga in
                        NavigationLink(destination: MangaDetailView(vm: .init(for: vm.src, mangaId: manga.wrappedValue.id))) {
                            ImageWithTextOver(title: manga.wrappedValue.title, imageUrl: manga.wrappedValue.thumbnailUrl)
                                .frame(height: 180)
                                .task { await vm.fetchMoreIfPossible(for: manga.wrappedValue) }
                                .overlay(alignment: .topTrailing) {
                                    if dataManager.isMangaInCollection(for: manga.wrappedValue, source: vm.src) {
                                        Image(systemName: "star")
                                            .symbolVariant(.fill)
                                            .padding(2)
                                            .foregroundColor(.white)
                                            .background(Color.blue)
                                            .clipShape(RoundedCorner(radius: 10, corners: [.topRight, .bottomLeft]))
                                    }
                                }
                                .contextMenu {
                                    if (!dataManager.isMangaInCollection(for: manga.wrappedValue, source: vm.src)) {
                                        if let collections = dataManager.getCollections() {
                                            ContextMenu(collections, manga: manga.wrappedValue)
                                        }
                                    }
                                }
                        }
                    }
                }
            }
        }
        .task { await vm.fetchList() }
        .refreshable { await vm.fetchList(clean: true) }
        .toolbar {
            ToolbarItem(placement: .principal) { Header() }
        }
        .navigationTitle(vm.getTitle())
    }
            
    func ContextMenu(_ collections: [MangaCollection], manga: SourceSmallManga) -> some View {
        ForEach(collections) { collection in
            // TODO: AsyncButton
            Button(action: {
                async {
                    await dataManager.insertManga(
                        base: manga,
                        source: vm.src,
                        collection: collection
                    )
                }
            }) {
                Text("Add to \(collection.name!)")
            }
        }
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
