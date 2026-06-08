//
//  CollectionGridPane.swift
//  Dokusho
//
//  Detail column of the Library split view: the manga grid/list for the
//  selected collection. Built from the collection id so switching collections
//  (via .id(id) in LibraryRootView) re-initializes its queries. Pushes
//  MangaDetail through the enclosing NavigationStack.
//

import SwiftUI
import GRDBQuery
import DataKit
import Common
import SharedUI
import MangaDetail

public struct CollectionGridPane: View {
    @Environment(\.appDatabase) var appDatabase
    @Environment(LibraryUpdater.self) var libraryUpdater
    @Preference(\.onlyUpdateAllRead) var onlyUpdateAllRead

    @Query<OneMangaCollectionRequest> var collection: MangaCollection?
    @Query<DetailedMangaInListRequest> var list: [DetailedMangaInList]

    @State private var showFilter = false
    @State private var refreshTask: Task<Void, Error>?
    @State private var migrationTarget: MigrationSheetItem?

    struct MigrationSheetItem: Identifiable {
        let id = UUID()
        let manga: DetailedMangaInList
    }

    public init(collectionId: MangaCollection.ID) {
        _collection = Query(OneMangaCollectionRequest(collectionId: collectionId))
        _list = Query(DetailedMangaInListRequest(requestType: .collection(collectionId: collectionId)))
    }

    public var body: some View {
        if let collection = collection {
            Group {
                if collection.useList ?? false { ListView() }
                else { GridView() }
            }
            .sheet(isPresented: $showFilter) { CollectionSettings(collection: collection) }
            .sheet(item: $migrationTarget) { item in
                MigrateMangaView(manga: item.manga, scraper: item.manga.scraper)
            }
            .searchable(text: $list.searchTerm)
            .toolbar { toolbar }
            .navigationTitle("\(collection.name) (\(list.count))")
            .queryObservation(.always)
            .onDisappear { cancelRefresh() }
        } else {
            ProgressView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    @ViewBuilder
    func GridView() -> some View {
        ScrollView {
            MangaList(mangas: list) { data in
                MangaInGrid(data: data)
            }
        }
        .refreshable { await refreshLibrary(libraryUpdater: libraryUpdater, collection: collection!, onlyUpdateAllRead: onlyUpdateAllRead) }
    }

    @ViewBuilder
    func MangaInGrid(data: DetailedMangaInList) -> some View {
        NavigationLink(value: data) {
            MangaCard(title: data.manga.title, imageUrl: data.manga.cover.absoluteString, chapterCount: data.unreadChapterCount)
                .contextMenu {
                    MangaLibraryContextMenu(manga: data.manga, scraper: data.scraper, count: data.unreadChapterCount) {
                        migrationTarget = MigrationSheetItem(manga: data)
                    }
                }
                .mangaCardFrame()
                .id(data.id)
        }
    }

    @ViewBuilder
    func ListView() -> some View {
        List(list) { data in
            MangaInList(data: data)
        }
        .refreshable { await refreshLibrary(libraryUpdater: libraryUpdater, collection: collection!, onlyUpdateAllRead: onlyUpdateAllRead) }
        .listStyle(PlainListStyle())
    }

    @ViewBuilder
    func MangaInList(data: DetailedMangaInList) -> some View {
        NavigationLink(value: data) {
            HStack {
                MangaCard(imageUrl: data.manga.cover.absoluteString, chapterCount: data.unreadChapterCount)
                    .mangaCardFrame(width: 90, height: 120)
                    .id(data.id)

                Text(data.manga.title)
                    .lineLimit(3)
            }
            .contextMenu {
                MangaLibraryContextMenu(manga: data.manga, scraper: data.scraper, count: data.unreadChapterCount) {
                    migrationTarget = MigrationSheetItem(manga: data)
                }
            }
            .frame(height: 120)
        }
    }

    var toolbar: some ToolbarContent {
        ToolbarItemGroup(placement: .topBarTrailing) {
            Button(action: { showFilter.toggle() }) {
                Image(systemName: "line.3.horizontal.decrease")
            }
        }
    }

    func refreshLibrary(libraryUpdater: LibraryUpdater, collection: MangaCollection, onlyUpdateAllRead: Bool) async {
        guard refreshTask == nil else { return }

        refreshTask = Task {
            try? await libraryUpdater.refreshCollection(collection: collection, onlyAllRead: onlyUpdateAllRead)
        }

        try? await refreshTask?.value
    }

    func cancelRefresh() {
        refreshTask?.cancel()
    }
}
