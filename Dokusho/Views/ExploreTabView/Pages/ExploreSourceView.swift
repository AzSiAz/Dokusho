//
//  ExploreSourceView.swift
//  ExploreSourceView
//
//  Created by Stephan Deumier on 14/08/2021.
//

import SwiftUI
import MangaScraper
import GRDBQuery

struct ExploreSourceView: View {
    @Query<MangaInCollectionsRequest> var mangas: [MangaInCollection]
    @Query(MangaCollectionRequest()) var collections
    
    @StateObject var vm: ExploreSourceVM
    
    var columns: [GridItem] = [GridItem(.adaptive(minimum: 120, maximum: 120))]
    
    init(scraper: Scraper) {
        _vm = .init(wrappedValue: .init(for: scraper))
        _mangas = Query(MangaInCollectionsRequest(srcId: scraper.id))
    }
    
    var body: some View {
        ScrollView {
            if vm.error {
                VStack {
                    Text("Something weird happened, try again")
                    AsyncButton(action: { await vm.fetchList(clean: true) }) {
                        Image(systemSymbol: .arrowClockwise)
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
                        NavigationLink(destination: MangaDetailView(mangaId: manga.id, scraper: vm.scraper, showDismiss: false)) {
                            let found = mangas.first { $0.mangaId == manga.id }
                            ImageWithTextOver(title: manga.title, imageUrl: manga.thumbnailUrl)
                                .frame(height: 180)
                                .contextMenu { ContextMenu(manga: manga) }
                                .task { await vm.fetchMoreIfPossible(for: manga) }
                                .overlay(alignment: .topTrailing) {
                                    if found != nil {
                                        Text(found!.collectionName)
                                            .lineLimit(1)
                                            .padding(2)
                                            .foregroundColor(.primary)
                                            .background(.thinMaterial, in: RoundedCorner(radius: 10, corners: [.topRight, .bottomLeft]) )
                                    }
                                }
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .task { await vm.fetchList() }
        .toolbar {
            ToolbarItem(placement: .principal) { Header() }
            ToolbarItem(placement: .navigationBarTrailing) {
                AsyncButton(action: { await vm.fetchList(clean: true) }) {
                    Image(systemSymbol: .arrowClockwise)
                }
            }
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
            Task { await vm.fetchList(clean: true) }
        }
    }
    
    @ViewBuilder
    func ContextMenu(manga: SourceSmallManga) -> some View {
        ForEach(collections) { collection in
            AsyncButton(action: { await vm.addToCollection(smallManga: manga, collection: collection) }) {
                Text("Add to \(collection.name)")
            }
        }
    }
}
