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
import DataKit
import SharedUI
import MangaDetail

public struct SearchSourceListScreen: View {
    @Query(MangaCollectionRequest()) var collections
    
    @State var searchText: String = ""
    @State var isSearchFocused: Bool = true
    
    var scrapers: [Scraper]
    
    public init(scrapers: [Scraper]) {
        self.scrapers = scrapers
    }

    public var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            DebouncedSearchBar(debouncedText: $searchText, isFocused: $isSearchFocused)
                .padding(.top, 10)
                .padding(.horizontal, 10)
            ForEach(scrapers) { scraper in
                ScraperSearch(scraper: scraper, textToSearch: $searchText, collections: collections)
            }
        }
        .padding(.top, 5)
    }
}

public struct ScraperSearch: View {
    @Query<MangaInCollectionsRequest> var mangasInCollection: [MangaInCollection]

    @StateObject var vm: SearchScraperVM
    @Binding var textToSearch: String
    
    var collections: [MangaCollection]
    
    public init(scraper: Scraper, textToSearch: Binding<String>, collections: [MangaCollection]) {
        self.collections = collections
        _textToSearch = textToSearch
        _vm = .init(wrappedValue: .init(scraper: scraper))
        _mangasInCollection = Query(MangaInCollectionsRequest(srcId: scraper.id))
    }
    
    public var body: some View {
        VStack(alignment: .leading) {
            if textToSearch.isEmpty {
                EmptyView()
            } else {
                HStack {
                    Text(vm.scraper.name)
                        .padding(.top, 15)
                        .padding(.leading, 15)
                    Spacer()
                }
                Group {
                    if vm.isLoading && vm.mangas.isEmpty {
                        ProgressView()
                            .padding(.leading, 25)
                    } else if !vm.isLoading && vm.mangas.isEmpty {
                        Text("No Results founds")
                            .padding(.leading, 15)
                    }
                    else {
                        SearchResult()
                    }
                }
                .frame(height: !vm.isLoading && vm.mangas.isEmpty ? 50 : 180)
            }
        }
        .padding(.bottom, 10)
        .onChange(of: textToSearch) { _, text in
            Task {
                await vm.fetchData(textToSearch: textToSearch)
            }
        }
        .sheet(item: $vm.selectedManga) { manga in
            NavigationView {
                MangaDetail(mangaId: manga.id, scraper: vm.scraper)
            }
        }
    }
    
    @ViewBuilder
    func SearchResult() -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack {
                ForEach(vm.mangas) { manga in
                    let found = mangasInCollection.first { $0.mangaId == manga.id }
                    MangaCard(title: manga.title, imageUrl: manga.thumbnailUrl, collectionName: found?.collectionName ?? "")
                        .mangaCardFrame()
                        .contextMenu { ContextMenu(manga: manga) }
                        .task { await self.vm.fetchMoreIfPossible(for: manga) }
                        .onTapGesture { vm.selectedManga = manga }
                        .padding(.trailing, vm.mangas.last == manga ? 15 : 0)
                        .padding(.leading, vm.mangas.first == manga ? 15 : 0)
                }

                if vm.isLoading && !vm.mangas.isEmpty {
                    ProgressView()
                }
            }
        }
    }
    
    @ViewBuilder
    func ContextMenu(manga: SourceSmallManga) -> some View {
        ForEach(collections) { collection in
            Button(action: {
                Task {
                    await vm.addToCollection(smallManga: manga, collection: collection)
                }
            }) {
                Text("Add to \(collection.name)")
            }
        }
    }
}
