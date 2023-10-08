//
//  ExploreSourceView.swift
//  ExploreSourceView
//
//  Created by Stephan Deumier on 14/08/2021.
//

import SwiftUI
import MangaScraper
import DataKit
import SharedUI
import MangaDetail
import Collections

enum LoadingState {
    case loadingFirstPage, loadingNextPage, error(String), loaded
}

public struct ExploreSourceView: View {
    @Environment(\.modelContext) var modelContext
    @Environment(ScraperService.self) var scraperService
    
    @Query var inCollection: [Manga]
    @Query(.allMangaCollectionByPosition(.forward)) var collections: [MangaCollection]
    
    @Bindable private var scraper: Scraper
    
    @State private var nextPage = 1
    @State private var isLoading = false

    @State private var type: SourceFetchType = .latest
    @State private var error = false
    @State private var mangas = OrderedSet<SourceSmallManga>()


    public init(scraper: Bindable<Scraper>) {
        self._scraper = scraper
        self._inCollection = Query(.mangaInCollection(scraperId: scraper.id))
    }
    
    public var body: some View {
        ScrollView {
            switch(error, mangas.count) {
            case (true, 0): ErrorBlock()
            case (false, 0): LoadingBlock()
            case (true, _): ErrorWithMangaInListBlock()
            case (false, _): MangaListBlock()
            case (_, 0): LoadingBlock()
            }
        }
        .refreshable { await fetchList(clean: true) }
        .toolbar {
            ToolbarItem(placement: .principal) {
                Header()
            }
        }
        .navigationTitle(scraper.name)
        .task { await fetchList(clean: true) }
        .onChange(of: type) { _, _ in Task { await fetchList(clean: true, typeChange: true) } }
        .navigationDestination(for: SourceSmallManga.self) { manga in
            MangaDetailScreen(mangaId: manga.id, scraperId: scraper.id)
        }
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
            NavigationLink(value: manga) {
                let found = inCollection.first { $0.mangaId == manga.id }
                MangaCard(title: manga.title, imageUrl: manga.thumbnailUrl, collectionName: found?.collection?.name)
                    .mangaCardFrame()
                    .contextMenu { ContextMenu(manga: manga) }
                    .task {
                        if mangas.last == manga {
                            await fetchList()
                        }
                    }
            }
            .buttonStyle(.plain)
        }
        .padding(.bottom, 10)
        
        if isLoading {
            LoadingBlock()
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
        ContentUnavailableView(
            "Refresh",
            systemImage: "bolt.horizontal.circle",
            description: Text("Source might be unavailable... \n Please use pull to refresh")
        )
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
            AsyncButton(action: { await addToCollection(id: manga.id, collection: collection) }) {
                Text("Add to \(collection.name)")
            }
        }
    }
}

extension ExploreSourceView {
    func fetchList(clean: Bool = false, typeChange: Bool = false) async {
        guard isLoading == false else { return }
        
        defer {
            isLoading = false
        }
        
        if clean {
            nextPage = 1
            if typeChange {
                self.mangas = OrderedSet()
                self.error = false
            }
        } else {
            self.isLoading = true
            self.error = false
        }
        
        do {
            guard let source = scraperService.getSource(sourceId: scraper.id) else { return }

            let newManga = try await type == .latest ? source.fetchLatestUpdates(page: nextPage) : source.fetchPopularManga(page: nextPage)
            
            withAnimation {
                if clean { self.mangas = OrderedSet(newManga.mangas) }
                else { self.mangas.append(contentsOf: newManga.mangas) }

                self.nextPage += 1
            }
        } catch {
            withAnimation {
                self.error = true
            }
        }
    }
    
    func addToCollection(id: SourceSmallManga.ID, collection: MangaCollection) async {
        guard
            let source = scraperService.getSource(sourceId: scraper.id),
            let sourceManga = try? await source.fetchMangaDetail(id: id)
        else { return }
        
        let manga = Manga(from: sourceManga, scraperId: scraper.id)
        modelContext.insert(manga)
        
        collection.mangas.append(manga)
    }
}
