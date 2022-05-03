//
//  ManageCollectionsModal.swift
//  Dokusho (iOS)
//
//  Created by Stephan Deumier on 26/06/2021.
//

import SwiftUI
import GRDBQuery
import Combine
import ASCollectionView

struct CollectionPage: View {
    @Environment(\.appDatabase) var appDatabase
    @EnvironmentObject var libraryUpdater: LibraryUpdater

    @Query<OneMangaCollectionRequest> var collection: MangaCollection?
    @Query<DetailedMangaInCollectionRequest> var list: [DetailedMangaInList]

    @State var showFilter = false
    @State var reload = true
    @State var selected: DetailedMangaInList?
    @Preference(\.useNewCollectionView) var useNewCollectionView
    
    var columns: [GridItem] = [GridItem(.adaptive(130))]
    
    init(collection : MangaCollection) {
        _collection = Query(OneMangaCollectionRequest(collectionId: collection.id))
        _list = Query(DetailedMangaInCollectionRequest(collection: collection))
    }
    
    var body: some View {
        Group {
            if !useNewCollectionView {
                ScrollView {
                    LazyVGrid(columns: columns) {
                        ForEach(list) { data in
                            Button(action: { selected = data }){
                                MangaCardView(manga: data.manga, count: data.unreadChapterCount)
                            }
                            .buttonStyle(.plain)
                            .id(data.id)
                        }
                    }
                }
            }
            else {
                ASCollectionView(data: list, dataID: \.id) { data, _ in
                    Button(action: { selected = data }){
                        MangaCardView(manga: data.manga, count: data.unreadChapterCount)
                    }
                    .buttonStyle(.plain)
                    .id(data.id)
                }
                .alwaysBounceVertical(true)
                .layout {
                    .grid(
                        layoutMode: .adaptive(withMinItemSize: 130),
                        itemSpacing: 5,
                        lineSpacing: 5,
                        itemSize: .absolute(180)
                    )
                }
                .edgesIgnoringSafeArea(.all)
            }
            
        }
        .navigate(item: $selected, destination: makeMangaDetailView(data:))
        .searchable(text: $list.searchTerm)
        .toolbar { toolbar }
        .navigationTitle("\(collection?.name ?? "") (\(list.count))")
        .navigationBarTitleDisplayMode(.automatic)
        .mirrorAppearanceState(to: $list.isAutoupdating, $collection.isAutoupdating)
    }
    
    func makeMangaDetailView(data: DetailedMangaInList) -> some View {
        MangaDetailView(mangaId: data.manga.mangaId, scraper: data.scraper)
    }
    
    var toolbar: some ToolbarContent {
        ToolbarItemGroup(placement: .navigationBarTrailing) {
            AsyncButton(action: { try? await libraryUpdater.refreshCollection(collection: collection!) }) {
                Image(systemName: "arrow.clockwise")
            }
            
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
}
