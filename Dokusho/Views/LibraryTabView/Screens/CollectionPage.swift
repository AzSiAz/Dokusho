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
        ScrollView {
            MangaList(mangas: list) { data in
                MangaCard(title: data.manga.title, imageUrl: data.manga.cover.absoluteString, chapterCount: data.unreadChapterCount)
                    .contextMenu { MangaLibraryContextMenu(manga: data.manga, count: data.unreadChapterCount) }
                    .mangaCardFrame()
                    .onTapGesture { selected = data }
            }
        }
        .refresher(style: .system, action: refreshLibrary)
        .navigate(item: $selected, destination: makeMangaDetailView(data:))
        .searchable(text: $list.searchTerm)
        .toolbar { toolbar }
        .navigationTitle("\(collection?.name ?? "") (\(list.count))")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $selectedGenre) { MangaInCollectionForGenre(genre: $0) }
        .queryObservation(.onAppear)
    }
    
    func refreshLibrary() async {
        try? await libraryUpdater.refreshCollection(collection: collection!)
    }
    
    func makeMangaDetailView(data: DetailedMangaInList) -> some View {
        MangaDetail(mangaId: data.manga.mangaId, scraper: data.scraper, selectGenre: selectGenre(genre:))
    }
    
    var toolbar: some ToolbarContent {
        ToolbarItemGroup(placement: .navigationBarTrailing) {
            Button(action: { showFilter.toggle() }) {
                Image(systemName: "line.3.horizontal.decrease.circle")
                    .symbolVariant(collection!.filter != .all ? .fill : .none)
            }
            .sheet(isPresented: $showFilter) {
                CollectionSettings(collection: collection!)
            }
        }
    }
    
    func getItemPerRows() -> Int {
        UIScreen.isLargeScreen ? 6 : 3
    }
    
    func selectGenre(genre: String) -> Void {
        self.selectedGenre = genre
    }
}
