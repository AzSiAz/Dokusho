//
//  ManageCollectionsModal.swift
//  Dokusho (iOS)
//
//  Created by Stephan Deumier on 26/06/2021.
//

import SwiftUI
import GRDBQuery
import Combine
import DataKit
import Common
import SharedUI
import MangaDetail
import Refresher

struct CollectionPage: View {    
    @Environment(\.appDatabase) var appDatabase
    @EnvironmentObject var libraryUpdater: LibraryUpdater

    @Query<OneMangaCollectionRequest> var collection: MangaCollection?
    @Query<DetailedMangaInListRequest> var list: [DetailedMangaInList]

    @State var showFilter = false
    @State var reload = true
    @State var selected: DetailedMangaInList?
    @State var selectedGenre: String?
    
    init(collection : MangaCollection) {
        _collection = Query(OneMangaCollectionRequest(collectionId: collection.id))
        _list = Query(DetailedMangaInListRequest(requestType: .collection(collectionId: collection.id)))
    }
    
    var body: some View {
        if let collection = collection {
            Group {
                if collection.useList ?? false {
                    List(list) { data in
                        MangaInList(data: data)
                    }
                    .refreshable { await refreshLibrary() }
                    .listStyle(PlainListStyle())
                } else {
                    ScrollView {
                        MangaList(mangas: list) { data in
                            MangaInGrid(data: data)
                        }
                    }
                    .refresher(style: .system2, action: refreshLibrary)
                }
            }
            .sheet(isPresented: $showFilter) {
                CollectionSettings(collection: collection)
            }
            .navigate(item: $selected, destination: makeMangaDetailView(data:))
            .searchable(text: $list.searchTerm)
            .toolbar { toolbar }
            .navigationTitle("\(collection.name) (\(list.count))")
            .sheet(item: $selectedGenre) { MangaInCollectionForGenre(genre: $0) }
            .queryObservation(.onAppear)
        }
    }
    
    @ViewBuilder
    func MangaInGrid(data: DetailedMangaInList) -> some View {
        MangaCard(title: data.manga.title, imageUrl: data.manga.cover.absoluteString, chapterCount: data.unreadChapterCount)
            .contextMenu { MangaLibraryContextMenu(manga: data.manga, count: data.unreadChapterCount) }
            .mangaCardFrame()
            .onTapGesture { selected = data }
    }
    
    @ViewBuilder
    func MangaInList(data: DetailedMangaInList) -> some View {
        NavigationLink(destination: makeMangaDetailView(data: data)) {
            HStack {
                MangaCard(imageUrl: data.manga.cover.absoluteString, chapterCount: data.unreadChapterCount)
                    .mangaCardFrame(width: 90, height: 120)
                    .id(data.id)
                
                Text(data.manga.title)
                    .lineLimit(3)
            }
            .contextMenu { MangaLibraryContextMenu(manga: data.manga, count: data.unreadChapterCount) }
            .frame(height: 120)
        }
    }
    
    var toolbar: some ToolbarContent {
        ToolbarItemGroup(placement: .navigationBarTrailing) {
            Button(action: { showFilter.toggle() }) {
                Image(systemName: "line.3.horizontal.decrease")
            }
        }
    }
    
    func refreshLibrary() async {
        try? await libraryUpdater.refreshCollection(collection: collection!)
    }
    
    func makeMangaDetailView(data: DetailedMangaInList) -> some View {
        MangaDetail(mangaId: data.manga.mangaId, scraper: data.scraper, selectGenre: selectGenre(genre:))
    }
    
    func selectGenre(genre: String) -> Void {
        self.selectedGenre = genre
    }
}
