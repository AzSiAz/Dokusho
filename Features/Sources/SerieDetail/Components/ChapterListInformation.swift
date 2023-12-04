import SwiftUI
import DataKit
import Reader
import Common

public struct ChapterListInformation: View {
    @Environment(ReaderManager.self) var readerManager
    @Environment(UserPreferences.self) var userPreferences
    
    @Query<SerieChaptersForSerie> var chapters: [SerieChapter]
    
    var serie: Serie
    var scraper: Scraper
    
    public init(serie: Serie, scraper: Scraper) {
        self.serie = serie
        self.scraper = scraper
        self._chapters = Query(SerieChaptersForSerie(serieID: serie.id))
    }

    public var body: some View {
        LazyVStack {
            HStack {
                Text("Chapter List")
                    .font(.title3)
                Spacer()
                HStack {
                    ChaptersButton(filter: $chapters.filter, order: $chapters.order)
                }
            }
            .frame(height: 24)
            .padding(.vertical, 10)
            .padding(.horizontal, 15)

            chapterCollections
                .padding(.horizontal, 10)
        }
    }
    
    @ViewBuilder
    var chapterCollections: some View {
        Group {
            if let chapter = nextUnreadChapter(chapters: chapters) {
                Group {
                    if let url = chapter.externalUrl {
                        Link(destination: url) {
                            NextUnreadChapter()
                        }
                    } else {
                        Button(action: { selectChapter(chapter: chapter) }) {
                            NextUnreadChapter()
                        }
                    }
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
                .padding(.horizontal)
            }

            let chs = userPreferences.showExternalChapters ? chapters : chapters.filter { $0.externalUrl == nil }
            ForEach(chs) { chapter in
                ChapterListRow(serie: serie, scraper: scraper, chapter: chapter, chapters: chapters)
            }
        }
    }

    @ViewBuilder
    func NextUnreadChapter() -> some View {
        Text("Read next unread chapter")
            .frame(minWidth: 0, maxWidth: .infinity)
    }

    @ViewBuilder
    func ChaptersButton(filter: Binding<SerieChaptersForSerie.Filter>, order: Binding<SerieChaptersForSerie.Order>) -> some View {
        Button(action: { filter.wrappedValue.toggle() }) {
            Image(systemName: "line.3.horizontal.decrease.circle")
                .resizable()
                .scaledToFit()
                .symbolVariant(filter.wrappedValue != .all ? .fill : .none)
        }
        .padding(.trailing, 5)
        
        Button(action: { order.wrappedValue.toggle() }) {
            Image(systemName: "chevron.up.chevron.down")
                .resizable()
                .scaledToFit()
        }
    }
}

private extension ChapterListInformation {
    func nextUnreadChapter(chapters: [SerieChapter]) -> SerieChapter? {
        return chapters
            .lazy
            .sorted { $0.volume ?? 0 < $1.volume ?? 0 }
            .sorted { $0.chapter < $1.chapter }
            .first { $0.readAt == nil }
    }
    
    func selectChapter(chapter: SerieChapter) {
        readerManager.selectChapter(chapter: chapter, serie: serie, scraper: scraper, chapters: chapters)
    }
}
