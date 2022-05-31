//
//  ExploreSourceView.swift
//  ExploreSourceView
//
//  Created by Stephan Deumier on 14/08/2021.
//

import SwiftUI
import MangaScraper
import GRDBQuery
import DataKit
import SharedUI
import MangaDetail
import Refresher

struct ExploreSourceView: View {
    @Query<MangaInCollectionsRequest> var mangas: [MangaInCollection]
    @Query(MangaCollectionRequest()) var collections
    
    @StateObject var vm: ExploreSourceVM
    
    var columns: [GridItem] = [GridItem(.adaptive(130))]
    
    init(scraper: Scraper) {
        _vm = .init(wrappedValue: .init(for: scraper))
        _mangas = Query(MangaInCollectionsRequest(srcId: scraper.id))
    }
    
    var body: some View {
        ScrollView {
            switch(vm.error, vm.fromSegment, vm.fromRefresher) {
            case (true, true, true): ErrorBlock()
            case (true, false, false): ErrorBlock()
            case (false, false, false): MangaListBlock()
            case (false, false, true): MangaListBlock()
            case (false, true, false): LoadingBlock()
            case (false, true, true): MangaListBlock()
            case (true, false, true): ErrorBlock()
            case (true, true, false): ErrorBlock()
            }
        }
        .refresher(style: .system, action: vm.refresh(done:))
        .task(id: vm.type) { await vm.fetchList(clean: true) }
        .toolbar { ToolbarItem(placement: .principal) { Header() } }
        .navigationTitle(vm.getTitle())
    }
    
    @ViewBuilder
    func MangaListBlock() -> some View {
        LazyVGrid(columns: columns, spacing: 10) {
            ForEach(vm.mangas) { manga in
                NavigationLink(destination: MangaDetail(mangaId: manga.id, scraper: vm.scraper)) {
                    let found = mangas.first { $0.mangaId == manga.id }
                    MangaCard(title: manga.title, imageUrl: manga.thumbnailUrl, collectionName: found?.collectionName ?? "")
                        .mangaCardFrame()
                        .contextMenu { ContextMenu(manga: manga) }
                        .task { await vm.fetchMoreIfPossible(for: manga) }
                }
                .buttonStyle(.plain)
            }
        }
    }
    
    @ViewBuilder
    func LoadingBlock() -> some View {
        ProgressView()
            .progressViewStyle(.circular)
            .frame(maxWidth: .infinity)
            .scaleEffect(1.5)
            .padding(.bottom, 10)
    }
    
    @ViewBuilder
    func ErrorBlock() -> some View {
        VStack {
            Text("Something weird happened, try again")
            AsyncButton(action: { await vm.fetchList(clean: true) }) {
                Image(systemName: "arrow.clockwise")
            }
        }
    }
    
    @ViewBuilder
    func Header() -> some View {
        Picker("Order", selection: $vm.type) {
            ForEach(SourceFetchType.allCases) { type in
                Text(type.rawValue).tag(type)
            }
        }
        .pickerStyle(.segmented)
        .frame(maxWidth: 160)
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
