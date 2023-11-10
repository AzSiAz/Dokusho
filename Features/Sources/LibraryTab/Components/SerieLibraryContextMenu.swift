import SwiftUI
import DataKit

public struct SerieLibraryContextMenu: View {
    var serie: Serie
    var count: Int
    
    @Harmony var harmony
    
    public init(serie: Serie, count: Int) {
        self.serie = serie
        self.count = count
    }

    public var body: some View {
        if count != 0 {
            Button(action: { markAllChapterAsRead() }) {
                Text("Mark as read")
            }
        }
        
        if count == 0 {
            Button(action: { markAllChapterAsUnRead() }) {
                Text("Mark as unread")
            }
        }
    }
    
    func markAllChapterAsRead() {
        Task {
            let chapters = try await harmony.reader.read { db in
                return try SerieChapter.all().whereSerie(serieID: serie.id).fetchAll(db)
            }
            let chs = chapters.map {
                var ch = $0
                ch.setReadAt(date: .now)

                return ch
            }

            try await harmony.save(records: chs)
        }
    }
    
    func markAllChapterAsUnRead() {
        Task {
            let chapters = try await harmony.reader.read { db in
                return try SerieChapter.all().whereSerie(serieID: serie.id).fetchAll(db)
            }
            let chs = chapters.map {
                var ch = $0
                ch.setReadAt(date: nil)

                return ch
            }
            
            try await harmony.save(records: chs)
        }
    }
}
