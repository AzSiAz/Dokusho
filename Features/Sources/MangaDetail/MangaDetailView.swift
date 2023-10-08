//
//  MangaDetailView.swift
//  Dokusho
//
//  Created by Stephan Deumier on 06/06/2021.
//

import SwiftUI
import DataKit
import Reader
import Common
import SharedUI
import SwiftUILayouts

public struct MangaDetailScreen: View {
    @Environment(\.modelContext) var modelContext
    @Environment(ScraperService.self) var scraperService
    
    @State var scraper: Scraper? = nil
    @State var manga: Manga? = nil

    var mangaId: String
    var scraperId: UUID
    
    public init(mangaId: String, scraperId: UUID) {
        self.mangaId = mangaId
        self.scraperId = scraperId
    }
    
    public var body: some View {
        Group {
            if let manga, let scraper {
                InnerMangaDetail(manga: manga, scraper: scraper)
            } else {
                ProgressView()
            }
        }
        .task {
            guard let source = scraperService.getSource(sourceId: scraperId) else { return }
            guard
                let found = try? modelContext.fetch(.getScrapersBySourceId(id: scraperId)),
                let scraper = found.first
            else { return }
            
            self.scraper = scraper
            
            guard
                let found = try? modelContext.fetch(.mangaBySourceId(scraperId: scraper.id, id: mangaId)),
                let manga = found.first
            else {
                guard let sourceManga = try? await source.fetchMangaDetail(id: mangaId)
                else { return }
                
                let manga = Manga(from: sourceManga, scraperId: scraper.id)
                modelContext.insert(manga)
                self.manga = manga
                
                return
            }
            
            self.manga = manga
        }
    }
}

public struct InnerMangaDetail: View {
    @Environment(\.horizontalSizeClass) var horizontalSize

    @Query(.allMangaCollectionByPosition(.forward)) var collections: [Collection]

    @Bindable var manga: Manga
    @Bindable var scraper: Scraper

    @State var orientation = DeviceOrientation()
    @State var readerManager = ReaderManager()
    @State var showMoreDesc = false
    
    public init(manga: Manga, scraper: Scraper) {
        self.manga = manga
        self.scraper = scraper
    }
    
    public var body: some View {
        Group {
            if horizontalSize == .regular {
                LargeBody
            } else {
                CompactBody
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
//                Link(destination: self.vm.getMangaURL()) {
//                    Image(systemName: "safari")
//                }
            }
        }
        .fullScreenCover(item: $readerManager.selectedChapter) { data in
            ReaderView(vm: .init(manga: data.manga, chapter: data.chapter, scraper: data.scraper, chapters: data.chapters))
                .environment(readerManager)
        }
        .environment(readerManager)
    }
    
    @ViewBuilder
    var LargeBody: some View {
        Grid {
            GridRow {
                ScrollView {
                    HeaderRow
                    ActionRow
                    SynopsisRow
                    GenreRow
                }
                .id("Detail")
                .gridCellColumns(6)
                
                HStack {
                    Divider()
                }
                .gridCellColumns(1)

                ScrollView {
//                    ChapterListInformation(manga: data.manga, scraper: vm.scraper)
//                        .disabled(vm.refreshing)
//                        .padding(.bottom)
                }
                .id("Chapter")
//                .refreshable { await vm.update() }
                .gridCellColumns(5)
            }
        }
    }
    
    @ViewBuilder
    var CompactBody: some View {
        ScrollView {
            HeaderRow
            ActionRow
            SynopsisRow
            GenreRow
//            ChapterListInformation(manga: data.manga, scraper: data.scraper!)
//                .disabled(vm.refreshing)
//                .padding(.bottom)
        }
//        .refreshable { await vm.update() }
    }
    
    @ViewBuilder
    var HeaderRow: some View {
        HStack(alignment: .top) {
            MangaCard(imageUrl: manga.cover)
                .mangaCardFrame()
                .padding(.leading, 10)
            
            VStack(spacing: 0) {
                VStack(alignment: .leading) {
                    Text(manga.title)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                        .font(.subheadline.bold())
                }
                .padding(.bottom, 5)
                
                VStack(alignment: .center) {
                    VStack {
                        ForEach(manga.authors) { author in
                            Text(author)
                                .font(.caption.italic())
                        }
                    }
                    .padding(.bottom, 5)
                    
                    Text(manga.status.rawValue)
                        .font(.callout.bold())
                        .padding(.bottom, 5)
                    
                    Text(scraper.name)
                        .font(.callout.bold())
                }
            }
            .frame(maxWidth: .infinity)
        }
    }
    
    @ViewBuilder
    var ActionRow: some View {
        ControlGroup {
            Button(action: {
                withAnimation {
//                    vm.addToCollection.toggle()
                }
            }) {
                VStack(alignment: .center, spacing: 1) {
                    Image(systemName: "heart")
                        .symbolVariant(manga.collection != nil ? .fill : .none)
                    Text(manga.collection?.name ?? "Favoris")
                }
            }
            .disabled(collections.count == 0)
            .buttonStyle(.plain)
//            .actionSheet(isPresented: $vm.addToCollection) {
//                var actions: [ActionSheet.Button] = []
//                    
//                collections.forEach { col in
//                    actions.append(.default(
//                        Text(col.name),
//                        action: {
//                            vm.updateMangaInCollection(data: data, col.id)
//                        }
//                    ))
//                }
//
//                if let collectionName = data.mangaCollection?.name {
//                    actions.append(.destructive(
//                        Text("Remove from \(collectionName)"),
//                        action: {
//                            vm.updateMangaInCollection(data: data)
//                        }
//                    ))
//                }
//
//                actions.append(.cancel())
//
//                return ActionSheet(title: Text("Choose collection"), buttons: actions)
//            }
            
            Divider()
                .padding(.horizontal)
            
            AsyncButton(action: {
//                await vm.resetCache()
            }) {
                VStack(alignment: .center, spacing: 1) {
                    Image(systemName: "xmark.bin.circle")
                    Text("Reset cache")
                }
            }
            .disabled(true)
        }
        .controlGroupStyle(.navigation)
        .frame(height: 50)
        .padding(.top)
        .padding(.bottom, 5)
        .padding(.horizontal)
    }
    
    @ViewBuilder
    var SynopsisRow: some View {
        VStack(spacing: 5) {
            Text(manga.synopsis)
                .lineLimit(showMoreDesc ? nil : 4)
                .fixedSize(horizontal: false, vertical: true)
            
            HStack {
                Spacer()
                Button(action: { withAnimation {
                    showMoreDesc.toggle()
                } }) {
                    Text("Show \(!showMoreDesc ? "more" : "less")")
                }
            }
        }
        .padding([.bottom, .horizontal])
    }
    
    @ViewBuilder
    var GenreRow: some View {
        FlowLayout(alignment: .center) {
            ForEach(manga.genres) { genre in
                Button(genre, action: {  })
                    .buttonStyle(.bordered)
            }
        }
    }
}

