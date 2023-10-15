//
//  ManageCollectionsModal.swift
//  Dokusho (iOS)
//
//  Created by Stephan Deumier on 26/06/2021.
//

import SwiftUI
import DataKit
import Common
import SharedUI
import SerieDetail
import DynamicCollection

@Observable
public class SerieCollectionPageViewModel {
    private var refreshTask: Task<Void, Error>?
    
    var showFilter = false
    var reload = true
    var selectedGenre: String?
    
    public func refreshLibrary(libraryUpdater: LibraryUpdater, collection: SerieCollection, onlyUpdateAllRead: Bool) async {
        guard refreshTask == nil else { return }

        await MainActor.run {
            UIApplication.shared.isIdleTimerDisabled = true
        }
        
        refreshTask = Task {
            try? await libraryUpdater.refreshCollection(collection: collection, onlyAllRead: onlyUpdateAllRead)
        }
        
        try? await refreshTask?.value
        
        await MainActor.run {
            UIApplication.shared.isIdleTimerDisabled = false
        }
    }
    
    @MainActor
    public func cancelRefresh() {
        refreshTask?.cancel()
        UIApplication.shared.isIdleTimerDisabled = false
    }
    
    public func selectGenre(genre: String) -> Void {
        self.selectedGenre = genre
    }
}

public struct SerieCollectionPage: View {
    @Environment(LibraryUpdater.self) var libraryUpdater
    @Environment(UserPreferences.self) var userPreference

//    @GRDBQuery.Query<OneMangaCollectionRequest> var collection: MangaCollection?
//    @GRDBQuery.Query<DetailedMangaInListRequest> var list: [DetailedMangaInList]
    
    @State var vm: SerieCollectionPageViewModel = .init()
    
    public init(collection : SerieCollection) {
//        _collection = Query(OneMangaCollectionRequest(collectionId: collection.id))
//        _list = Query(DetailedMangaInListRequest(requestType: .collection(collectionId: collection.id)))
    }
    
    public var body: some View {
//        if let collection = collection {
//            Group {
//                if collection.useList ?? false { ListView() }
//                else { GridView() }
//            }
//            .sheet(isPresented: $vm.showFilter) { CollectionSettings(collection: collection) }
//            .searchable(text: $list.searchTerm)
//            .toolbar { toolbar }
//            .navigationTitle("\(collection.name) (\(list.count))")
//            .queryObservation(.always)
//            .onDisappear { vm.cancelRefresh() }
//        }
        EmptyView()
    }
    
//    @ViewBuilder
//    func GridView() -> some View {
//        ScrollView {
//            MangaList(mangas: list) { data in
//                MangaInGrid(data: data)
//            }
//        }
//        .refreshable { await vm.refreshLibrary(libraryUpdater: libraryUpdater, collection: collection!, onlyUpdateAllRead: userPreference.onlyUpdateAllRead) }
//    }
    
//    @ViewBuilder
//    func MangaInGrid(data: DetailedMangaInList) -> some View {
//        NavigationLink(value: data) {
//            MangaCard(title: data.manga.title, imageUrl: data.manga.cover, chapterCount: data.unreadChapterCount)
//                .contextMenu { MangaLibraryContextMenu(manga: data.manga, count: data.unreadChapterCount) }
//                .mangaCardFrame()
//                .id(data.id)
//        }
//    }
//    
//    @ViewBuilder
//    func ListView() -> some View {
//        List(list) { data in
//            MangaInList(data: data)
//        }
//        .refreshable { await vm.refreshLibrary(libraryUpdater: libraryUpdater, collection: collection!, onlyUpdateAllRead: userPreference.onlyUpdateAllRead) }
//        .listStyle(PlainListStyle())
//    }
//    
//    @ViewBuilder
//    func MangaInList(data: DetailedMangaInList) -> some View {
//        NavigationLink(value: data) {
//            HStack {
//                MangaCard(imageUrl: data.manga.cover, chapterCount: data.unreadChapterCount)
//                    .mangaCardFrame(width: 90, height: 120)
//                    .id(data.id)
//                
//                Text(data.manga.title)
//                    .lineLimit(3)
//            }
//            .contextMenu { MangaLibraryContextMenu(manga: data.manga, count: data.unreadChapterCount) }
//            .frame(height: 120)
//        }
//    }
//    
//    var toolbar: some ToolbarContent {
//        ToolbarItemGroup(placement: .navigationBarTrailing) {
//            Button(action: { vm.showFilter.toggle() }) {
//                Image(systemName: "line.3.horizontal.decrease")
//            }
//        }
//    }
}
