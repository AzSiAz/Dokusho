import SwiftUI
import DataKit
import Reader

public struct ChapterListRow: View {
    @Environment(ReaderManager.self) var readerManager
    
    @Query() var chapters: [SerieChapter]
    
    @Bindable var serie: Serie
    @Bindable var scraper: Scraper
    @Bindable var chapter: SerieChapter
    
    public var body: some View {
        HStack {
            if let url = chapter.externalUrl {
                Link(destination: url) {
                    content
                }
                .buttonStyle(.plain)
                .padding(.vertical, 5)
            } else {
                Button(action: {
                    readerManager.selectChapter(chapter: chapter, serie: serie, scraper: scraper, chapters: chapters)
                }) {
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
                Text(chapter.title ?? "")
                Text(chapter.uploadedAt?.formatted() ?? "")
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
        if (chapter.readAt != nil) {
            Button(action: { changeChapterStatus(for: chapter) }) {
                Text("Mark as read")
            }
        }
        else {
            Button(action: { changeChapterStatus(for: chapter) }) {
                Text("Mark as unread")
            }
        }

        if hasPreviousUnreadChapter(for: chapter, chapters: chapters) {
            Button(action: { changePreviousChapterStatus(for: chapter, in: chapters) }) {
                Text("Mark previous as read")
            }
        }
        else {
            Button(action: { changePreviousChapterStatus(for: chapter, in: chapters) }) {
                Text("Mark previous as unread")
            }
        }
    }
}

extension ChapterListRow {
    func changeChapterStatus(for chapter: SerieChapter) {
//        do {
//            try database.write { db in
//                try MangaChapterDB.markChapterAs(newStatus: status, db: db, chapterId: chapter.id)
//            }
//        } catch(let err) {
//            print(err)
//        }
    }

    func changePreviousChapterStatus(for chapter: SerieChapter, in chapters: [SerieChapter]) {
//        do {
//            try database.write { db in
//                try chapters
//                    .filter { status == .unread ? !$0.isUnread : $0.isUnread }
//                    .filter { chapter.position < $0.position }
//                    .forEach { try MangaChapterDB.markChapterAs(newStatus: status, db: db, chapterId: $0.id) }
//            }
//        } catch(let err) {
//            print(err)
//        }
    }

    func hasPreviousUnreadChapter(for chapter: SerieChapter, chapters: [SerieChapter]) -> Bool {
//        return chapters
//            .filter { chapter.position < $0.position }
//            .contains { $0.isUnread }

        return false
    }

    func nextUnreadChapter(chapters: [SerieChapter]) -> SerieChapter? {
//        return chapters
//            .sorted { $0.position > $1.position }
//            .first { $0.isUnread }
        
        return nil
    }
}
