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
import Refresher

public struct MangaDetail: View {
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
                ViewThatFits(in: .horizontal) {
                    LargeBody(data)
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
        HStack(alignment: .top, spacing: 5) {
            ScrollView {
                VStack {
                    HeaderRow(data)
                    ActionRow(data)
                    SynopsisRow(data, isLarge: true)
                }
                .id("Detail")
            }
            .refresher(style: .system, action: vm.update)
            .frame(minWidth: 250, alignment: .leading)
            
            Divider()
            
            ScrollView {
                ChapterListInformation(manga: data.manga, scraper: vm.scraper)
                    .disabled(vm.refreshing)
                    .padding(.bottom)
            }
            .id("Chapter")
        }
    }
    
    @ViewBuilder
    func CompactBody(_ data: MangaWithDetail) -> some View {
        ScrollView {
            HeaderRow(data)
            ActionRow(data)
            SynopsisRow(data, isLarge: false)
            ChapterListInformation(manga: data.manga, scraper: data.scraper!)
                .disabled(vm.refreshing)
                .padding(.bottom)
        }
        .refresher(style: .system, action: vm.update)
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
                    
                    // TODO: Change to source name
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
        }
        .controlGroupStyle(.navigation)
        .frame(height: 50)
        .padding(.top)
        .padding(.bottom, 5)
        .padding(.horizontal)
    }
    
    @ViewBuilder
    func SynopsisRow(_ data: MangaWithDetail , isLarge: Bool) -> some View {
        VStack {
            VStack(spacing: 5) {
                Text(data.manga.synopsis)
                    .lineLimit(vm.showMoreDesc ? nil : 4)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(width: .greedy, alignment: .leading)
                
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

            HStack {
                Text("Genres:")
                Spacer()
            }
            .padding(.horizontal)
            
            GeometryReader { proxy in
                FlexibleView(data: data.manga.genres, availableWidth: proxy.size.width, spacing: 5, alignment: .center) { genre in
                    Button(genre, action: { selectGenre?(genre) })
                        .buttonStyle(.bordered)
                }
                .frame(width: .greedy, alignment: .center)
            }
            .padding(.leading)
        }
    }
}
