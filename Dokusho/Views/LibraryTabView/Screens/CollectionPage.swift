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
    @Query<DetailedMangaInCollectionRequest> var list: [DetailedMangaInList]

    @State var showFilter = false
    @State var reload = true
    @State var selected: DetailedMangaInList?
    @State var selectedGenre: String?
    
    var columns: [GridItem] = [GridItem(.adaptive(minimum: 130, maximum: 130))]
    
    init(collection : MangaCollection) {
        _collection = Query(OneMangaCollectionRequest(collectionId: collection.id))
        _list = Query(DetailedMangaInCollectionRequest(collection: collection))
    }
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns) {
                ForEach(list) { data in
                    Button(action: { selected = data }){
                        MangaCard(title: data.manga.title, imageUrl: data.manga.cover.absoluteString, chapterCount: data.unreadChapterCount)
                            .contextMenu { MangaLibraryContextMenu(manga: data.manga, count: data.unreadChapterCount) }
                            .mangaCardFrame()
                    }
                    .buttonStyle(.plain)
                    .id(data.id)
                }
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
                NavigationView {
                    List {
                        Section("Filter") {
                            Picker("Change collection filter", selection: $list.collectionFilter) {
                                ForEach(MangaCollectionFilter.allCases, id: \.self) { filter in
                                    Text(filter.rawValue).tag(filter)
                                }
                            }
                        }

                        Section("Order") {
                            Picker("Change collection order field", selection: $list.collectionOrder.field) {
                                ForEach(MangaCollectionOrder.Field.allCases, id: \.self) { filter in
                                    Text(filter.rawValue).tag(filter)
                                }
                            }
                            Picker("Change collection order direction", selection: $list.collectionOrder.direction) {
                                ForEach(MangaCollectionOrder.Direction.allCases, id: \.self) { filter in
                                    Text(filter.rawValue).tag(filter)
                                }
                            }
                        }
                    }
                    .navigationTitle(Text("Modify Filter"))
                    .onChange(of: $list.collectionFilter.wrappedValue, perform: { updateCollectionFilter(newFilter: $0) })
                    .onChange(of: $list.collectionOrder.field.wrappedValue, perform: { updateCollectionOrder(direction: nil, field: $0) })
                    .onChange(of: $list.collectionOrder.direction.wrappedValue, perform: { updateCollectionOrder(direction: $0, field: nil) })
                }
            }
        }
    }
    
    func getItemPerRows() -> Int {
        UIScreen.isLargeScreen ? 6 : 3
    }
    
    func updateCollectionFilter(newFilter: MangaCollectionFilter) {
        guard let collection = collection else { return }

        do {
            try appDatabase.database.write { db in
                guard var foundCollection = try MangaCollection.fetchOne(db, id: collection.id) else { return }
                print(foundCollection)
                foundCollection.filter = newFilter
                print(foundCollection)

                try foundCollection.save(db)
            }
        } catch(let err) {
            print(err)
        }
    }
    
    func updateCollectionOrder(direction: MangaCollectionOrder.Direction? = nil, field: MangaCollectionOrder.Field? = nil) {
        guard let collection = collection else { return }
        
        do {
            try appDatabase.database.write { db in
                guard var foundCollection = try MangaCollection.fetchOne(db, id: collection.id) else { return }
                if let direction = direction { foundCollection.order.direction = direction }
                if let field = field { foundCollection.order.field = field }

                try foundCollection.save(db)
            }
        } catch(let err) {
            print(err)
        }
    }
    
    func selectGenre(genre: String) -> Void {
        self.selectedGenre = genre
    }
}
