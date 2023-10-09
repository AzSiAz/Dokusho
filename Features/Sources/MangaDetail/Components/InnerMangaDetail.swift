import SwiftUI
import DataKit
import Reader
import Common
import SharedUI
import SwiftUILayouts

public struct InnerMangaDetail: View {
    @Environment(\.horizontalSizeClass) var horizontalSize

    @Query(.allMangaCollectionByPosition(.forward)) var collections: [SerieCollection]

    @Bindable var manga: Serie
    @Bindable var scraper: Scraper

    @State var orientation = DeviceOrientation()
    @State var readerManager = ReaderManager()
    @State var showMoreDesc = false
    @State var addToCollectionSheet = false
    
    public init(manga: Serie, scraper: Scraper) {
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
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if let url = getMangaURL() {
                    Link(destination: url) {
                        Image(systemName: "safari")
                    }
                }
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
                .refreshable { await update() }
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
        .refreshable { await update() }
    }
    
    @ViewBuilder
    var HeaderRow: some View {
        HStack(alignment: .top) {
            MangaCard(imageUrl: manga.cover)
                .mangaCardFrame()
                .padding(.leading, 10)
            
            VStack(spacing: 0) {
                VStack(alignment: .leading) {
                    Text(manga.title ?? "")
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                        .font(.subheadline.bold())
                }
                .padding(.bottom, 5)
                
                VStack(alignment: .center) {
                    VStack {
                        ForEach(manga.authors ?? []) { author in
                            Text(author)
                                .font(.caption.italic())
                        }
                    }
                    .padding(.bottom, 5)
                    
                    Text(manga.status?.rawValue ?? "")
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
                    addToCollectionSheet.toggle()
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
            .actionSheet(isPresented: $addToCollectionSheet) {
                var actions: [ActionSheet.Button] = []

                collections.forEach { col in
                    actions.append(.default(
                        Text(col.name ?? ""),
                        action: {
                            manga.collection = col
                        }
                    ))
                }

                if let collectionName = manga.collection?.name {
                    actions.append(.destructive(
                        Text("Remove from \(collectionName)"),
                        action: {
                            manga.collection = nil
                        }
                    ))
                }

                actions.append(.cancel())

                return ActionSheet(title: Text("Choose collection"), buttons: actions)
            }
            
            Divider()
                .padding(.horizontal)
            
            AsyncButton(action: {
                await resetCache()
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
            Text(manga.synopsis ?? "")
                .lineLimit(showMoreDesc ? nil : 4)
                .fixedSize(horizontal: false, vertical: true)
            
            HStack {
                Spacer()
                Button(action: {
                    withAnimation {
                        showMoreDesc.toggle()
                    }
                }) {
                    Text("Show \(!showMoreDesc ? "more" : "less")")
                }
            }
        }
        .padding([.bottom, .horizontal])
    }
    
    @ViewBuilder
    var GenreRow: some View {
        FlowLayout(alignment: .center) {
            ForEach(manga.genres ?? []) { genre in
                Button(genre, action: {  })
                    .buttonStyle(.bordered)
            }
        }
    }
}

extension InnerMangaDetail {
    func getMangaURL() -> URL? {
        guard
            let source = ScraperService.shared.getSource(sourceId: scraper.id),
            let mangaId = manga.mangaId
        else { return nil }

        return source.mangaUrl(mangaId: mangaId)
    }
    
    // TODO: Rework reset cache to avoid deleting chapter read/unread info
    func resetCache() async {}
    
    func update() async {
        guard
            let source = ScraperService.shared.getSource(sourceId: scraper.id),
            let mangaId = manga.mangaId,
            let sourceManga = try? await source.fetchMangaDetail(id: mangaId)
        else { return }
        
        print(sourceManga)
    }
}
