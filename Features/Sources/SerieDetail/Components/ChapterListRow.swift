import SwiftUI
import DataKit
import Reader

public struct ChapterListRow: View {
    @Environment(ReaderManager.self) var readerManager
    
    var chapters: [SerieChapter]
    var scraper: Scraper
    var chapter: SerieChapter
    var serie: Serie
    
    public init(serie: Serie, scraper: Scraper, chapter: SerieChapter, chapters: [SerieChapter]) {
        self.serie = serie
        self.scraper = scraper
        self.chapter = chapter
        self.chapters = chapters
    }
    
    public var body: some View {
        HStack {
            if let url = chapter.externalUrl {
                Link(destination: url) {
                    content
                }
                .buttonStyle(.plain)
                .padding(.vertical, 5)
            } else {
                Button(action: { selectChapter() }) {
                    content
                }
                .buttonStyle(.plain)
                .padding(.vertical, 5)
            }
        }
        .foregroundColor(chapter.readAt != nil ? Color.gray : Color.blue)
        .contextMenu { chapterRowContextMenu }
    }
    
    @ViewBuilder
    var content: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(chapter.title)
                Text(chapter.uploadedAt.formatted())
                    .font(.system(size: 12))
                if let readAt = chapter.readAt {
                    Text("Read At: \(readAt.formatted())")
                        .font(.system(size: 10))
                }
            }
        }
        
        Spacer()
        
        if chapter.externalUrl != nil {
            Image(systemName: "arrow.up.forward.app")
        } else {
            Button(action: { print("download")}) {
                Image(systemName: "icloud.and.arrow.down")
            }
        }
    }

    @ViewBuilder
    var chapterRowContextMenu: some View {
        Button(action: { changeChapterStatus(for: chapter) }) {
            if (chapter.readAt != nil) {
                Text("Mark as unread")
            } else {
                Text("Mark as read")
            }
        }
        
        let hasUnread = hasPreviousUnreadChapter(for: chapter, chapters: chapters)
        Button(action: { changePreviousChapterStatus(for: chapter, in: chapters, toRead: hasUnread) }) {
            if hasUnread {
                Text("Mark previous as read")
            } else {
                Text("Mark previous as unread")
            }
        }
    }
}

private extension ChapterListRow {
    func changeChapterStatus(for chapter: SerieChapter) {
//        withAnimation {
//            if chapter.readAt == nil {
//                chapter.readAt = .now
//            } else {
//                chapter.readAt = nil
//            }
//        }
    }

    func changePreviousChapterStatus(for chapter: SerieChapter, in chapters: [SerieChapter], toRead: Bool) {
//        do {
//            let toUpdate = chapters
//                .lazy
//                .filter { toRead ? $0.readAt == nil : $0.readAt != nil }
//                .filter { chapter.volume ?? 0 >= $0.volume ?? 0 }
//                .filter { chapter.chapter ?? 0 > $0.chapter ?? 0 }
//                .map { $0.persistentModelID }
//            
//            let context = ModelContext(modelContext.container)
//            context.autosaveEnabled = false
//            
//            for chapterId in toUpdate {
//                if let found = context.model(for: chapterId) as? SerieChapter {
//                    if toRead { found.readAt = .now }
//                    else { found.readAt = nil }
//                }
//            }
//            
//            try context.save()
//        } catch {
//            print(error)
//        }
    }

    func hasPreviousUnreadChapter(for chapter: SerieChapter, chapters: [SerieChapter]) -> Bool {
        return chapters
            .lazy
            .filter { chapter.volume ?? 0 >= $0.volume ?? 0 }
            .filter { chapter.chapter > $0.chapter }
            .contains { $0.readAt == nil }
    }
    
    func selectChapter() {
        readerManager.selectChapter(chapter: chapter, serie: serie, scraper: scraper, chapters: chapters)
    }
}
