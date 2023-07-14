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

public struct ExploreSourceView: View {
    @Query<MangaInCollectionsRequest> var mangas: [MangaInCollection]
    @Query(MangaCollectionRequest()) var collections
    
    @StateObject var vm: ExploreSourceVM

    public init(scraper: Scraper) {
        _vm = .init(wrappedValue: .init(for: scraper))
        _mangas = Query(MangaInCollectionsRequest(srcId: scraper.id))
    }
    
    public var body: some View {
        ScrollView {
            switch(vm.error, vm.fromSegment, vm.mangas.isEmpty) {
            case (true, _, true): ErrorBlock()
            case (true, _, false): ErrorWithMangaInListBlock()
            case (false, true, _): LoadingBlock()
            case (_, _, true): LoadingBlock()
            case (false, _, _): MangaListBlock()
            }
        }
        .refreshable { await vm.fetchList(clean: true) }
        .toolbar { ToolbarItem(placement: .principal) { Header() } }
        .navigationTitle(vm.getTitle())
        .task { await vm.fetchList(clean: true) }
        .onChange(of: vm.type) { _ in Task { await vm.fetchList(clean: true, typeChange: true) } }
    }
    
    @ViewBuilder
    func ErrorWithMangaInListBlock() -> some View {
        Group {
            MangaListBlock()
            ErrorBlock()
        }
    }
    
    @ViewBuilder
    func MangaListBlock() -> some View {
        MangaList(mangas: vm.mangas) { manga in
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
