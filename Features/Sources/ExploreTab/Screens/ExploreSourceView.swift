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
import Collections

public struct ExploreSourceView: View {
    @Environment(\.appDatabase) var database
    
    @Query<MangaInCollectionsRequest> var mangasInCollection: [MangaInCollection]
    @Query(MangaCollectionRequest()) var collections
    
    @State private var nextPage = 1
    @State private var isLoading = false
    @State private var initialized = false
    
    @State var mangas = OrderedSet<SourceSmallManga>()
    @State var error = false
    @State var type: SourceFetchType = .latest
    @State var selectedManga: SourceSmallManga?
    @State var fromSegment: Bool = false
    
    var scraper: Scraper

    public init(scraper: Scraper) {
        self.scraper = scraper
        _mangasInCollection = Query(MangaInCollectionsRequest(srcId: scraper.id))
    }
    
    public var body: some View {
        ScrollView {
            switch(error, fromSegment, mangas.isEmpty) {
            case (true, _, true): ErrorBlock()
            case (true, _, false): ErrorWithMangaInListBlock()
            case (false, true, _): LoadingBlock()
            case (_, _, true): LoadingBlock()
            case (false, _, _): MangaListBlock()
            }
        }
        .refreshable { await fetchList(clean: true) }
        .toolbar { ToolbarItem(placement: .principal) { Header() } }
        .navigationTitle(getTitle())
        .task { await initView() }
        .onChange(of: type) { _, _ in Task { await fetchList(clean: true, typeChange: true) } }
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
        MangaList(mangas: mangas) { manga in
            NavigationLink(destination: MangaDetail(mangaId: manga.id, scraper: scraper)) {
                let found = mangasInCollection.first { $0.mangaId == manga.id }
                MangaCard(title: manga.title, imageUrl: manga.thumbnailUrl, collectionName: found?.collectionName ?? "")
                    .mangaCardFrame()
                    .contextMenu { ContextMenu(manga: manga) }
                    .task { await fetchMoreIfPossible(for: manga) }
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
            AsyncButton(action: { await fetchList(clean: true) }) {
                Image(systemName: "arrow.clockwise")
            }
        }
    }
    
    @ViewBuilder
    func Header() -> some View {
        Picker("Order", selection: $type) {
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
            AsyncButton(action: { await addToCollection(smallManga: manga, collection: collection) }) {
                Text("Add to \(collection.name)")
            }
        }
    }
    
    @MainActor
    func fetchList(clean: Bool = false, typeChange: Bool = false) async {
        guard isLoading == false else { return }
        
        defer {
            fromSegment = false
            isLoading = false
        }
        
        if clean {
            nextPage = 1
            if typeChange {
                fromSegment = true
                error = false
            }
        } else {
            self.isLoading = true
            self.error = false
        }
        
        do {
            let newManga = try await type == .latest ? scraper.asSource()?.fetchLatestUpdates(page: nextPage) : scraper.asSource()?.fetchPopularManga(page: nextPage)
            
            withAnimation {
                if clean { self.mangas = OrderedSet(newManga!.mangas) }
                else { self.mangas.append(contentsOf: newManga!.mangas) }
                
                self.nextPage += 1
            }
        } catch {
            withAnimation {
                self.error = true
            }
        }
    }
    
    @MainActor
    func initView() async {
        if !initialized {
            await fetchList()
            
            withAnimation {
                self.initialized = true
            }
        }
    }
    
    func fetchMoreIfPossible(for manga: SourceSmallManga) async {
        if mangas.last == manga {
            return await fetchList()
        }
    }
    
    func getTitle() -> String {
        return "\(scraper.name) - \(type.rawValue)"
    }
    
    func addToCollection(smallManga: SourceSmallManga, collection: MangaCollection) async {
        guard let sourceManga = try? await scraper.asSource()?.fetchMangaDetail(id: smallManga.id) else { return }
        
        do {
            try await database.database.write { db -> Void in
                guard var manga = try Manga.all().forMangaId(smallManga.id, scraper.id).fetchOne(db) else {
                    var manga = try Manga.updateFromSource(db: db, scraper: scraper, data: sourceManga)
                    try manga.updateChanges(db) {
                        $0.mangaCollectionId = collection.id
                    }
                    return
                }
                
                try manga.updateChanges(db) {
                    $0.mangaCollectionId = collection.id
                }
            }
        } catch(let err) {
            print(err)
        }
    }
}
