//
//  ExploreSourceView.swift
//  ExploreSourceView
//
//  Created by Stephan Deumier on 14/08/2021.
//

import SwiftUI
import MangaSources

struct ExploreSourceView: View {
    @FetchRequest var mangas: FetchedResults<MangaEntity>
    @FetchRequest(sortDescriptors: [CollectionEntity.positionOrder], predicate: nil, animation: .default)
    var collections: FetchedResults<CollectionEntity>
    
    @StateObject var vm: ExploreSourceVM
    
    var columns: [GridItem] = [GridItem(.adaptive(minimum: 120, maximum: 120))]
    
    var body: some View {
        ScrollView {
            if vm.error {
                VStack {
                    Text("Something weird happened, try again")
                    AsyncButton(action: { await vm.fetchList(clean: true) }) {
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
                    ForEach(vm.mangas) { manga in
                        let isInCollection = mangas.first { $0.mangaId == manga.id } != nil
                        ImageWithTextOver(title: manga.title, imageUrl: manga.thumbnailUrl)
                            .frame(height: 180)
                            .onTapGesture { vm.selectedManga = manga }
                            .contextMenu { ContextMenu(manga: manga) }
                            .task { await vm.fetchMoreIfPossible(for: manga) }
                            .overlay(alignment: .topTrailing) {
                                if isInCollection {
                                    Image(systemName: "star")
                                        .symbolVariant(.fill)
                                        .padding(2)
                                        .foregroundColor(.white)
                                        .background(Color.blue)
                                        .clipShape(RoundedCorner(radius: 10, corners: [.topRight, .bottomLeft]))
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
            ToolbarItem(placement: .navigationBarTrailing) {
                AsyncButton(action: { await vm.fetchList(clean: true) }, {
                    Text("Refresh")
                })
            }
        }
        .sheetSizeAware(item: $vm.selectedManga) { manga in
            MangaDetailView(mangaId: manga.id, src: vm.src)
        }
        .navigationTitle(vm.getTitle())
    }
    
    func Header() -> some View {
        Picker("Order", selection: $vm.type) {
            ForEach(SourceFetchType.allCases) { type in
                Text(type.rawValue).tag(type)
            }
        }
        .pickerStyle(.segmented)
        .frame(maxWidth: 160)
        .onChange(of: vm.type) { _ in
            Task {
                await vm.fetchList(clean: true)
            }
        }
    }
    
    func ContextMenu(manga: SourceSmallManga) -> some View {
        ForEach(collections) { collection in
            AsyncButton(action: { await vm.addToCollection(smallManga: manga, collection: collection.objectID) }) {
                Text("Add to \(collection.name ?? "")")
            }
        }
    }
}
