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
    @State var selectedManga: SourceSmallManga?
    
    var fetchRequest: FetchRequest<Manga>
    var mangaInCollection: FetchedResults<Manga> { self.fetchRequest.wrappedValue }
    
    var columns: [GridItem] {
        var base = [
            GridItem(.fixed(120)),
            GridItem(.fixed(120)),
            GridItem(.fixed(120)),
        ]
        
        if UIDevice.current.userInterfaceIdiom == .pad || UIDevice.current.userInterfaceIdiom == .mac {
            base.append(contentsOf: base)
            base.append(contentsOf: [
                GridItem(.fixed(120)),
                GridItem(.fixed(120)),
                GridItem(.fixed(120)),
            ])
        }
        
        return base
    }
    
    init(vm: ExploreSourceVM) {
        self._vm = .init(wrappedValue: vm)
        self.fetchRequest = FetchRequest<Manga>(fetchRequest: Manga.fetchAllMangaInCollectionForSource(for: vm.src))
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
                        Button(action: { selectedManga = manga.wrappedValue }) {
                            ImageWithTextOver(title: manga.wrappedValue.title, imageUrl: manga.wrappedValue.thumbnailUrl)
//                                .id("\(manga.wrappedValue.id)@@\(vm.isInLib[manga.wrappedValue.id] ?? false)")
                                .frame(height: 180)
                                .task { await vm.fetchMoreIfPossible(for: manga.wrappedValue) }
                                .overlay(alignment: .topTrailing) {
                                    if mangaInCollection.first { $0.id == manga.id } != nil {
                                        Image(systemName: "star")
                                            .symbolVariant(.fill)
                                            .padding(2)
                                            .foregroundColor(.white)
                                            .background(Color.blue)
                                            .clipShape(RoundedCorner(radius: 10, corners: [.topRight, .bottomLeft]))
                                    }
                                }
                                .contextMenu {
                                    if mangaInCollection.first { $0.id == manga.id } == nil {
                                        if let collections = dataManager.getCollections() {
                                            ContextMenu(collections, manga: manga.wrappedValue)
                                        }
                                    }
                                }
                        }
                    }
                }
                .padding(.horizontal, 5)
            }
        }
        .sheetSizeAware(item: $selectedManga) { manga in
            MangaDetailView(vm: .init(for: vm.src, mangaId: manga.id))
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
//                    vm.isInLib[manga.id] = true
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
