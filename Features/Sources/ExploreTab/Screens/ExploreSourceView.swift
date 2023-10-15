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
    
    @Query var inCollection: [Serie]
    @Query(.allSerieCollectionByPosition(.forward)) var collections: [SerieCollection]
    
    @Bindable private var scraper: Scraper

    @State private var nextPage = 1
    @State private var isLoading = false
    @State private var type: SourceFetchType = .latest
    @State private var error = false
    @State private var series = OrderedSet<SourceSmallSerie>()

    public init(scraper: Scraper) {
        self.scraper = scraper
        self._inCollection = Query(.seriesInCollection(scraperId: scraper.id))
    }

    public var body: some View {
        ScrollView {
            switch(error, series.count) {
            case (true, 0): ErrorBlock
            case (false, 0): LoadingBlock
            case (true, _): ErrorWithSerieInListBlock
            case (false, _): SerieListBlock
            case (_, 0): LoadingBlock
            }
        }
        .refreshable { await fetchList(clean: true) }
        .toolbar {
            ToolbarItem(placement: .principal) {
                Header
            }
        }
        .navigationTitle(scraper.name)
        .task { await fetchList(clean: true) }
        .onChange(of: type) { _, _ in Task { await fetchList(clean: true, typeChange: true) } }
        .navigationDestination(for: SourceSmallSerie.self) { manga in
            SerieDetailScreen(serieId: manga.id, scraperId: scraper.id)
        }
    }
    
    @ViewBuilder
    var ErrorWithSerieInListBlock: some View {
        Group {
            SerieListBlock
            ErrorBlock
        }
    }
    
    @ViewBuilder
    var SerieListBlock: some View {
        MangaList(series: series) { manga in
            NavigationLink(value: manga) {
                let found = inCollection.first { $0.internalId == manga.id }
                SerieCard(title: manga.title, imageUrl: manga.thumbnailUrl, collectionName: found?.collection?.name)
                    .mangaCardFrame()
                    .contextMenu { ContextMenu(manga: manga) }
                    .task {
                        if series.last == manga {
                            await fetchList()
                        }
                    }
            }
            .buttonStyle(.plain)
        }
        .padding(.bottom, 10)
        
        if isLoading {
            LoadingBlock
        }
    }
    
    @ViewBuilder
    var LoadingBlock: some View {
        ProgressView()
            .progressViewStyle(.circular)
            .frame(maxWidth: .infinity)
            .scaleEffect(1.5)
            .padding(.bottom, 10)
    }
    
    @ViewBuilder
    var ErrorBlock: some View {
        ContentUnavailableView(
            "Refresh",
            systemImage: "bolt.horizontal.circle",
            description: Text("Source might be unavailable... \n Please use pull to refresh")
        )
    }
    
    @ViewBuilder
    var Header: some View {
        Picker("Order", selection: $type) {
            ForEach(SourceFetchType.allCases) { type in
                Text(type.rawValue).tag(type)
            }
        }
        .pickerStyle(.segmented)
        .frame(maxWidth: 160)
    }
    
    @ViewBuilder
    func ContextMenu(manga: SourceSmallSerie) -> some View {
        ForEach(collections) { collection in
            AsyncButton(action: { await addToCollection(id: manga.id, collection: collection) }) {
                Text("Add to \(collection.name ?? "")")
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
                self.series = OrderedSet()
                self.error = false
            }
        } else {
            self.isLoading = true
            self.error = false
        }
        
        do {
            guard let source = scraperService.getSource(sourceId: scraper.id) else { return }

            let newManga = try await type == .latest ? source.fetchLatestUpdates(page: nextPage) : source.fetchPopularSerie(page: nextPage)
            
            withAnimation {
                if clean { self.series = OrderedSet(newManga.data) }
                else { self.series.append(contentsOf: newManga.data) }

                self.nextPage += 1
            }
        } catch {
            withAnimation {
                self.error = true
            }
        }
    }
    
    @MainActor
    func addToCollection(id: SourceSmallSerie.ID, collection: SerieCollection) async {
        guard
            let source = scraperService.getSource(sourceId: scraper.id),
            let sourceManga = try? await source.fetchSerieDetail(serieId: id)
        else { return }
        
        let serie = Serie(from: sourceManga, scraperId: scraper.id)
        modelContext.insert(serie)
        
        collection.series?.append(serie)
    }
}
