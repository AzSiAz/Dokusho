import SwiftUI
import DataKit
import Reader
import Common
import SharedUI
import SwiftUILayouts

public struct InnerSerieDetail: View {
    @Environment(\.horizontalSizeClass) var horizontalSize
    @Environment(\.modelContext) var modelContext
    @Environment(SerieService.self) var serieService

    @Query(.allSerieCollectionByPosition(.forward)) var collections: [SerieCollection]

    @Bindable var serie: Serie
    @Bindable var scraper: Scraper

    @State var orientation = DeviceOrientation()
    @State var readerManager = ReaderManager()
    @State var showMoreDesc = false
    @State var addToCollectionSheet = false

    public init(serie: Serie, scraper: Scraper) {
        self.serie = serie
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
            ReaderView(vm: .init(serie: data.serie, chapter: data.chapter, scraper: data.scraper, chapters: data.chapters))
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
                    ChapterListInformation(serie: serie, scraper: scraper)
//                        .disabled(refreshing)
                        .padding(.bottom)
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
            ChapterListInformation(serie: serie, scraper: scraper)
//                .disabled(refreshing)
                .padding(.bottom)
        }
        .refreshable { await update() }
    }
    
    @ViewBuilder
    var HeaderRow: some View {
        HStack(alignment: .top) {
            SerieCard(imageUrl: serie.cover)
                .mangaCardFrame()
                .padding(.leading, 10)
            
            VStack(spacing: 0) {
                VStack(alignment: .leading) {
                    Text(serie.title ?? "")
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                        .font(.subheadline.bold())
                }
                .padding(.bottom, 5)
                
                VStack(alignment: .center) {
                    VStack {
                        ForEach(serie.authors ?? []) { author in
                            Text(author)
                                .font(.caption.italic())
                        }
                    }
                    .padding(.bottom, 5)
                    
                    Text(serie.status?.rawValue ?? "")
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
                        .symbolVariant(serie.collection != nil ? .fill : .none)
                    Text(serie.collection?.name ?? "Favoris")
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
                            serie.collection = col
                        }
                    ))
                }

                if let collectionName = serie.collection?.name {
                    actions.append(.destructive(
                        Text("Remove from \(collectionName)"),
                        action: {
                            serie.collection = nil
                        }
                    ))
                }

                actions.append(.cancel())

                return ActionSheet(title: Text("Choose collection"), buttons: actions)
            }
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
            Text(serie.synopsis ?? "")
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
            ForEach(serie.genres ?? []) { genre in
                Button(genre, action: {  })
                    .buttonStyle(.bordered)
            }
        }
    }
}

extension InnerSerieDetail {
    func getMangaURL() -> URL? {
        guard
            let source = ScraperService.shared.getSource(sourceId: scraper.id),
            let mangaId = serie.internalId
        else { return nil }

        return source.serieUrl(serieId: mangaId)
    }

    func update() async {
        guard
            let source = ScraperService.shared.getSource(sourceId: scraper.id),
            let serieId = serie.internalId,
            let _ = try? await serieService.update(source: source, serieId: serieId, in: modelContext.container)
        else { return }
    }
}
