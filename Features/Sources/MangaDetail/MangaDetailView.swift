//
//  MangaDetailView.swift
//  Dokusho
//
//  Created by Stephan Deumier on 06/06/2021.
//

import SwiftUI
import GRDBQuery
import DataKit
import Reader
import Common
import SharedUI
import SwiftUILayouts

public struct MangaDetail: View {
    @Environment(\.horizontalSizeClass) var horizontalSize
    @Query(MangaCollectionRequest()) var collections
    @Query<MangaDetailRequest> var data: MangaWithDetail?

    @StateObject var vm: MangaDetailVM
    @StateObject var orientation: DeviceOrientation = DeviceOrientation()
    @StateObject var readerManager = ReaderManager()

    let selectGenre: ((_ genre: String) -> Void)?
    
    public init(mangaId: String, scraper: Scraper, selectGenre: ((_ genre: String) -> Void)? = nil) {
        _data = .init(.init(mangaId: mangaId, scraper: scraper))
        _vm = .init(wrappedValue: .init(for: scraper, mangaId: mangaId))
        
        self.selectGenre = selectGenre
    }
    
    public var body: some View {
        Group {
            if vm.error && data == nil {
                VStack {
                    Text("Something weird happened, try again")
                    AsyncButton(action: { await vm.update() }) {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
            else if let data = data {
                if horizontalSize == .regular {
                    LargeBody(data)
                } else {
                    CompactBody(data)
                }
            }
            else {
                ProgressView()
                    .progressViewStyle(.circular)
                    .frame(maxWidth: .infinity)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Link(destination: self.vm.getMangaURL()) {
                    Image(systemName: "safari")
                }
            }
        }
        .fullScreenCover(item: $readerManager.selectedChapter) { data in
            ReaderView(vm: .init(manga: data.manga, chapter: data.chapter, scraper: data.scraper, chapters: data.chapters), readerManager: readerManager)
        }
        .environmentObject(readerManager)
    }
    
    @ViewBuilder
    func LargeBody(_ data: MangaWithDetail) -> some View {
        Grid {
            GridRow {
                ScrollView {
                    HeaderRow(data)
                    ActionRow(data)
                    SynopsisRow(synopsis: data.manga.synopsis)
                    GenreRow(genres: data.manga.genres)
                }
                .id("Detail")
                .gridCellColumns(6)
                
                HStack {
                    Divider()
                }
                .gridCellColumns(1)

                ScrollView {
                    ChapterListInformation(manga: data.manga, scraper: vm.scraper)
                        .disabled(vm.refreshing)
                        .padding(.bottom)
                }
                .id("Chapter")
                .refreshable { await vm.update() }
                .gridCellColumns(5)
            }
        }
    }
    
    @ViewBuilder
    func CompactBody(_ data: MangaWithDetail) -> some View {
        ScrollView {
            HeaderRow(data)
            ActionRow(data)
            SynopsisRow(synopsis: data.manga.synopsis)
            GenreRow(genres: data.manga.genres)
            ChapterListInformation(manga: data.manga, scraper: data.scraper!)
                .disabled(vm.refreshing)
                .padding(.bottom)
        }
        .refreshable { await vm.update() }
    }
    
    @ViewBuilder
    func HeaderRow(_ data: MangaWithDetail) -> some View {
        HStack(alignment: .top) {
            MangaCard(imageUrl: data.manga.cover.absoluteString)
                .mangaCardFrame()
                .padding(.leading, 10)
            
            VStack(spacing: 0) {
                VStack(alignment: .leading) {
                    Text(data.manga.title)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                        .font(.subheadline.bold())
                }
                .padding(.bottom, 5)
                
                VStack(alignment: .center) {
                    VStack {
                        ForEach(data.manga.authors) { author in
                            Text(author)
                                .font(.caption.italic())
                        }
                    }
                    .padding(.bottom, 5)
                    
                    Text(data.manga.status.rawValue)
                        .font(.callout.bold())
                        .padding(.bottom, 5)
                    
                    Text(data.scraper?.name ?? "No Name")
                        .font(.callout.bold())
                }
            }
            .frame(maxWidth: .infinity)
        }
    }
    
    @ViewBuilder
    func ActionRow(_ data: MangaWithDetail) -> some View {
        ControlGroup {
            Button(action: {
                withAnimation {
                    vm.addToCollection.toggle()
                }
            }) {
                VStack(alignment: .center, spacing: 1) {
                    Image(systemName: "heart")
                        .symbolVariant(data.mangaCollection != nil ? .fill : .none)
                    Text(data.mangaCollection?.name ?? "Favoris")
                }
            }
            .disabled(collections.count == 0)
            .buttonStyle(.plain)
            .actionSheet(isPresented: $vm.addToCollection) {
                var actions: [ActionSheet.Button] = []
                    
                collections.forEach { col in
                    actions.append(.default(
                        Text(col.name),
                        action: {
                            vm.updateMangaInCollection(data: data, col.id)
                        }
                    ))
                }

                if let collectionName = data.mangaCollection?.name {
                    actions.append(.destructive(
                        Text("Remove from \(collectionName)"),
                        action: {
                            vm.updateMangaInCollection(data: data)
                        }
                    ))
                }

                actions.append(.cancel())

                return ActionSheet(title: Text("Choose collection"), buttons: actions)
            }
            
            Divider()
                .padding(.horizontal)
            
            AsyncButton(action: { await vm.resetCache() }) {
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
    func SynopsisRow(synopsis: String) -> some View {
        VStack(spacing: 5) {
            Text(synopsis)
                .lineLimit(vm.showMoreDesc ? nil : 4)
                .fixedSize(horizontal: false, vertical: true)
            
            HStack {
                Spacer()
                Button(action: { withAnimation {
                    vm.showMoreDesc.toggle()
                } }) {
                    Text("Show \(!vm.showMoreDesc ? "more" : "less")")
                }
            }
        }
        .padding([.bottom, .horizontal])
    }
    
    @ViewBuilder
    func GenreRow(genres: [String]) -> some View {
        FlowLayout(alignment: .center) {
            ForEach(genres) { genre in
                Button(genre, action: { selectGenre?(genre) })
                    .buttonStyle(.bordered)
            }
        }
    }
}

