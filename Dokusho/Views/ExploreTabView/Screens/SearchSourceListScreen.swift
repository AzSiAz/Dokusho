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
    @Query(MangaCollectionRequest()) var collections
    
    @State var searchText: String = ""
    @State var isSearchFocused: Bool = true
    
    var scrapers: [Scraper]

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            SearchBarWithDebounce(debouncedText: $searchText, isFocused: $isSearchFocused)
                .padding(.top, 10)
                .padding(.horizontal, 10)
            ForEach(scrapers) { scraper in
                ScraperSearch(scraper: scraper, textToSearch: $searchText, collections: collections)
            }
        }
        .padding(.top, 5)
    }
}

struct ScraperSearch: View {
    @Query<MangaInCollectionsRequest> var mangasInCollection: [MangaInCollection]

    @StateObject var vm: SearchScraperVM
    @Binding var textToSearch: String
    
    var collections: [MangaCollection]
    
    init(scraper: Scraper, textToSearch: Binding<String>, collections: [MangaCollection]) {
        self.collections = collections
        _textToSearch = textToSearch
        _vm = .init(wrappedValue: .init(scraper: scraper))
        _mangasInCollection = Query(MangaInCollectionsRequest(srcId: scraper.id))
    }
    
    var body: some View {
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
                        ScrollView(.horizontal, showsIndicators: false) {
                            LazyHStack {
                                ForEach(vm.mangas) { manga in
                                    MangaCard(manga: manga)
                                        .onTapGesture {
                                            vm.selectedManga = manga
                                        }
                                }
                                
                                if vm.isLoading && !vm.mangas.isEmpty {
                                    ProgressView()
                                }
                            }
                        }
                    }
                }
                .frame(height: !vm.isLoading && vm.mangas.isEmpty ? 50 : 180)
            }
        }
        .padding(.bottom, 10)
        .onChange(of: textToSearch) { text in
            Task {
                await vm.fetchData(textToSearch: textToSearch)
            }
        }
        .sheet(item: $vm.selectedManga) { manga in
            NavigationView {
                MangaDetailView(mangaId: manga.id, scraper: vm.scraper)
            }
        }
    }
    
    @ViewBuilder
    func MangaCard(manga: SourceSmallManga) -> some View {
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
