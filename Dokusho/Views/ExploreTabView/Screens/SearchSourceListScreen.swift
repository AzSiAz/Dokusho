//
//  SearchSourceList.swift
//  Dokusho
//
//  Created by Stephan Deumier on 21/04/2022.
//

import Foundation
import SwiftUI
import Combine
import GRDBQuery
import MangaScraper

struct SearchSourceListScreen: View {
    @Environment(\.isSearching) var isSearching
    
    @Query(MangaCollectionRequest()) var collections
    
    @State var searchText: String = ""
    
    var scrapers: [Scraper]

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            TextFieldWithDebounce(debouncedText: $searchText)
                .padding(.top, 10)
            
            if searchText.isEmpty {
                EmptyView()
            }
            else {
                ForEach(scrapers) { scraper in
                    ScraperSearch(scraper: scraper, textToSearch: searchText, collections: collections)
                }
            }
        }
    }
}

struct ScraperSearch: View {
    @Query<MangaInCollectionsRequest> var mangasInCollection: [MangaInCollection]

    @StateObject var vm: SearchScraperVM
    
    var collections: [MangaCollection]
    
    init(scraper: Scraper, textToSearch: String, collections: [MangaCollection]) {
        self.collections = collections
        _vm = .init(wrappedValue: .init(scraper: scraper, textToSearch: textToSearch ))
        _mangasInCollection = Query(MangaInCollectionsRequest(srcId: scraper.id))
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(vm.scraper.name)
                    .padding(.top, 15)
                    .padding(.leading, 15)
                Spacer()
            }
            
            if vm.isLoading && vm.mangas.isEmpty {
                ProgressView()
                    .padding(.leading, 25)
            }
            else {
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack {
                        ForEach(vm.mangas) { manga in
                            mangaCard(manga: manga)
                        }
                        
                        if vm.isLoading && !vm.mangas.isEmpty {
                            ProgressView()
                        }
                    }
                }
            }
        }
        .padding(.bottom, 10)
        .task { await vm.fetchData(reset: true) }
    }
    
    @ViewBuilder
    func mangaCard(manga: SourceSmallManga) -> some View {
        ImageWithTextOver(title: manga.title, imageUrl: manga.thumbnailUrl)
            .frame(width: 120, height: 180)
            .contextMenu { ContextMenu(manga: manga) }
            .task { await vm.fetchMoreIfPossible(for: manga) }
            .overlay(alignment: .topTrailing) {
                let found = mangasInCollection.first { $0.mangaId == manga.id }
                if found != nil {
                    Text(found!.collectionName)
                        .lineLimit(1)
                        .padding(2)
                        .foregroundColor(.primary)
                        .background(.thinMaterial, in: RoundedCorner(radius: 10, corners: [.topRight, .bottomLeft]) )
                }
            }
            .padding(.trailing, vm.mangas.last == manga ? 15 : 0)
            .padding(.leading, vm.mangas.first == manga ? 15 : 0)
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
