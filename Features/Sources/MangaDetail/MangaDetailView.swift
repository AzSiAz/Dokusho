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

    @State private var vm: MangaDetailVM
    @State private var orientation = DeviceOrientation()
    @State private var readerManager = ReaderManager()

    @State private var migrationItem: MigrationSheetItem?

    struct MigrationSheetItem: Identifiable {
        let id = UUID()
        let manga: Manga
        let scraper: Scraper
    }

    let selectGenre: ((_ genre: String) -> Void)?
    
    public init(mangaId: String, scraper: Scraper, selectGenre: ((_ genre: String) -> Void)? = nil) {
        _data = .init(.init(mangaId: mangaId, scraper: scraper))
        self.selectGenre = selectGenre
        self.vm = .init(for: scraper, mangaId: mangaId)
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
        .sheet(item: $migrationItem) { item in
            MigrateMangaView(manga: item.manga, scraper: item.scraper)
        }
        .environment(readerManager)
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
        HStack(alignment: .top, spacing: 16) {
            MangaCard(imageUrl: data.manga.cover.absoluteString)
                .mangaCardFrame()
                .shadow(color: .black.opacity(0.25), radius: 8, y: 4)
                .contextMenu {
                    if data.mangaCollection != nil {
                        Button(action: {
                            migrationItem = MigrationSheetItem(manga: data.manga, scraper: vm.scraper)
                        }) {
                            Label("Migrate to Another Source", systemImage: "arrow.triangle.swap")
                        }
                    }
                }

            VStack(alignment: .leading, spacing: 8) {
                Text(data.manga.title)
                    .font(.title2.bold())
                    .textSelection(.enabled)
                    .lineLimit(3)
                    .fixedSize(horizontal: false, vertical: true)

                if !data.manga.authors.isEmpty {
                    Text(data.manga.authors.joined(separator: ", "))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                HStack(spacing: 8) {
                    Label(data.manga.status.rawValue, systemImage: "book.closed")
                    if let name = data.scraper?.name {
                        Label(name, systemImage: "server.rack")
                    }
                }
                .font(.caption.weight(.medium))
                .foregroundStyle(.secondary)
                .padding(.top, 2)

                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal)
        .padding(.top, 8)
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
            .confirmationDialog("Choose collection", isPresented: $vm.addToCollection, titleVisibility: .visible) {
                ForEach(collections) { col in
                    Button(col.name) {
                        vm.updateMangaInCollection(data: data, col.id)
                    }
                }

                if let collectionName = data.mangaCollection?.name {
                    Button("Remove from \(collectionName)", role: .destructive) {
                        vm.updateMangaInCollection(data: data)
                    }
                }
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
                    .buttonStyle(.glass)
            }
        }
    }
}

