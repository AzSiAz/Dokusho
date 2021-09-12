//
//  HistoryTabView.swift
//  HistoryTabView
//
//  Created by Stephan Deumier on 12/09/2021.
//

import SwiftUI

struct HistoryTabView: View {
    @FetchRequest var chapters: FetchedResults<ChapterEntity>
    @State var searchTitle: String = ""
    @State var chapterStatus: ChapterStatus = .read
    
    init() {
        self._chapters = .init(sortDescriptors: [ChapterEntity.readAtOrder(), ChapterEntity.positionOrder()], predicate: ChapterEntity.forChapterStatusPredicate(status: [.read]), animation: .easeIn)
    }
    
    var body: some View {
        NavigationView {
            List {
                ForEach(chapters) { chapter in
//                    NavigationLink(destination: MangaDetailView(manga: chapter.manga!)) {
                        ChapterRow(chapter: chapter)
//                    }
                }
                .onDelete { offsets in
                    let toDelete = offsets.map { chapters[$0] }
//                    Task {
//                        await DataManager.shared.markChaptersAs(for: toDelete, status: .unread)
//                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Picker("Chapter Status", selection: $chapterStatus) {
                        Text(ChapterStatus.read.rawValue).tag(ChapterStatus.read)
                        Text("All").tag(ChapterStatus.unread)
                    }
                    .frame(maxWidth: 150)
                    .pickerStyle(.segmented)
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
            }
            .listStyle(.plain)
            .searchable(text: $searchTitle)
            .navigationBarTitle("Reading History", displayMode: .large)
        }
    }
    
    @ViewBuilder
    func ChapterRow(chapter: ChapterEntity) -> some View {
        HStack {
            RemoteImageCacheView(url: chapter.manga!.cover!, contentMode: .fit)
                .frame(width: 80)
                .id(chapter.key)
            
            VStack(alignment: .leading) {
                Text(chapter.manga!.title!)
                Text(chapter.title ?? "No title...")
                
                if chapterStatus == .read { Text("Read at: \(chapter.readAt?.formatted() ?? "No date...")") }
                if chapterStatus == .unread { Text("Uploaded at: \(chapter.dateSourceUpload?.formatted() ?? "No date...")") }
            }
        }
        .frame(minHeight: 120)
    }
}

//struct FilteredHistoryView: View {
//
//    var body: some View {
//
//    }
//}
