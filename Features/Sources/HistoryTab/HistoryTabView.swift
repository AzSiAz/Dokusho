import SwiftUI
import DataKit
import SharedUI
import SerieDetail

public struct HistoryTabView: View {
    @Query(SerieChaptersHistoryRequest(filter: .read, searchTerm: "")) var chapters: [SerieChaptersHistory]
    @State var searchTerm: String = ""

    public init() {}

    public var body: some View {
        NavigationView {
            List {
                ForEach(chapters) { chapter in
                    ChapterRow(chapter)
                }
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Picker("Chapter Status", selection: $chapters.filter) {
                        Text(SerieChaptersHistoryRequest.ChapterStatusHistory.read.rawValue).tag(SerieChaptersHistoryRequest.ChapterStatusHistory.read)
                        Text(SerieChaptersHistoryRequest.ChapterStatusHistory.all.rawValue).tag(SerieChaptersHistoryRequest.ChapterStatusHistory.all)
                    }
                    .frame(maxWidth: 150)
                    .pickerStyle(.segmented)
                }
            }
            .overlay {
                NoContent()
            }
            .searchable(text: $chapters.searchTerm)
            .listStyle(PlainListStyle())
            .navigationBarTitle($chapters.filter.wrappedValue == .read ? "Reading history" : "Update history", displayMode: .large)
        }
        .navigationViewStyle(.columns)
    }

    @ViewBuilder
    func ChapterRow(_ chapter: SerieChaptersHistory) -> some View {
        NavigationLink(destination: SerieDetailScreen(serieID: chapter.serieInternalID, scraperID: chapter.scraperID)) {
            HStack {
                SerieCard(imageUrl: chapter.serieCover, contentMode: .fit)
                    .serieCardFrame(width: 90, height: 120)
                    .id(chapter.id)

                VStack(alignment: .leading) {
                    Text(chapter.serieTitle)
                        .lineLimit(2)
                        .font(.body)
                        .allowsTightening(true)
                    Text(chapter.serieChapterTitle)
                        .lineLimit(1)
                        .font(.callout.italic())

                    Group {
                        if $chapters.filter.wrappedValue == .read {
                            Text("Read at: \(chapter.serieChapterReadAt?.formatted() ?? "No date...")")
                        }
                        if $chapters.filter.wrappedValue == .all {
                            Text("Uploaded at: \(chapter.serieChapterUploadedAt.formatted())")
                        }
                    }
                    .font(.footnote)
                }
            }
            .frame(height: 120)
        }
    }
    
    @ViewBuilder
    func NoContent() -> some View {
        if $chapters.filter.wrappedValue == .read && chapters.isEmpty {
            ContentUnavailableView(
                "No read chapter",
                systemImage: "book",
                description: Text("Mark chapters as read or read one")
            )
        } else if $chapters.filter.wrappedValue == .all && chapters.isEmpty {
            ContentUnavailableView(
                "No chapter",
                systemImage: "book",
                description: Text("Browse manga")
            )
        }
    }
}
