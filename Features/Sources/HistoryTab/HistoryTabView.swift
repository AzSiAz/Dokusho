import SwiftUI
import DataKit
import SharedUI
import SerieDetail

public struct HistoryTabView: View {
    @AppStorage("HISTORY_SEGMENT_BAR") private var historyType = SerieChapterHistoryType.all
    @State var searchTerm: String = ""

    public init() {}

    public var body: some View {
        InnerHistoryTabView(historyType: $historyType, searchTerm: $searchTerm)
            .searchable(text: $searchTerm)
    }
}

public struct InnerHistoryTabView: View {
    @Query var chapters: [SerieChapter]

    @Binding var historyType: SerieChapterHistoryType
    @Binding var searchTerm: String

    public init(historyType: Binding<SerieChapterHistoryType>, searchTerm: Binding<String>) {
        self._historyType = historyType
        self._searchTerm = searchTerm
        self._chapters = Query(.chapters(historyType: historyType.wrappedValue, searchTerm: searchTerm.wrappedValue))
    }

    public var body: some View {
        NavigationView {
            List {
                ForEach(chapters) { chapter in
                    ChapterRow(chapter)
                }
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Picker("Chapter Status", selection: $historyType) {
                        Text(SerieChapterHistoryType.read.rawValue).tag(SerieChapterHistoryType.read)
                        Text(SerieChapterHistoryType.all.rawValue).tag(SerieChapterHistoryType.all)
                    }
                    .frame(maxWidth: 150)
                    .pickerStyle(.segmented)
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
            }
            .listStyle(PlainListStyle())
            .navigationBarTitle(historyType == .read ? "Reading history" : "Update history", displayMode: .large)
        }
        .navigationViewStyle(.columns)
    }

    @ViewBuilder
    func ChapterRow(_ chapter: SerieChapter) -> some View {
        if let serieID = chapter.serie?.internalId, let scraperID = chapter.serie?.scraperId {
            NavigationLink(destination: SerieDetailScreen(serieId: serieID, scraperId: scraperID)) {
                HStack {
                    SerieCard(imageUrl: chapter.serie?.cover, contentMode: .fit)
                        .serieCardFrame(width: 90, height: 120)
                        .id(chapter.persistentModelID)
    
                    VStack(alignment: .leading) {
                        Text(chapter.serie?.title ?? "")
                            .lineLimit(2)
                            .font(.body)
                            .allowsTightening(true)
                        Text(chapter.title ?? "")
                            .lineLimit(1)
                            .font(.callout.italic())
    
                        Group {
                            if historyType == .read { Text("Read at: \(chapter.readAt?.formatted() ?? "No date...")") }
                            if historyType == .all { Text("Uploaded at: \(chapter.uploadedAt?.formatted() ?? "No date...")") }
                        }
                        .font(.footnote)
                    }
                }
                .frame(height: 120)
            }
        }
    }
}
