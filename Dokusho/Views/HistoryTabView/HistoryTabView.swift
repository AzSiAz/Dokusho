//
//  HistoryTabView.swift
//  HistoryTabView
//
//  Created by Stephan Deumier on 12/09/2021.
//

import SwiftUI

struct HistoryTabView: View {
    @State var searchTitle: String = ""
    @State var status: ChapterStatusHistory = .read
    
    var body: some View {
        NavigationView {
            FilteredHistoryView(searchTerm: searchTitle, status: status)
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        Picker("Chapter Status", selection: $status) {
                            Text(ChapterStatusHistory.read.rawValue).tag(ChapterStatusHistory.read)
                            Text(ChapterStatusHistory.all.rawValue).tag(ChapterStatusHistory.all)
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
}

struct FilteredHistoryView: View {
    @FetchRequest var chapters: FetchedResults<ChapterEntity>
    
    var status: ChapterStatusHistory
    
    init(searchTerm: String, status: ChapterStatusHistory) {
        self.status = status
        self._chapters = .init(
            sortDescriptors: ChapterEntity.chapterHistoryOrder(status: status),
            predicate: ChapterEntity.chapterHistoryPredicate(status: status, searchTerm: searchTerm),
            animation: .easeIn
        )
    }
    
    var body: some View {
        List {
            ForEach(chapters) { chapter in
                ChapterRow(chapter: chapter)
            }
        }
        .id(UUID())
    }
    
    @ViewBuilder
    func ChapterRow(chapter: ChapterEntity) -> some View {
        NavigationLink(
            destination: MangaDetailView(
                mangaId: chapter.manga!.mangaId!,
                src: Int(chapter.manga!.source!.sourceId),
                showDismiss: false
            ),
            label: {
                HStack {
                    RemoteImageCacheView(url: chapter.manga!.cover!, contentMode: .fit)
                        .frame(width: 80)
                        .id(chapter.key)
                    
                    VStack(alignment: .leading) {
                        Text(chapter.manga!.title!)
                        Text(chapter.title ?? "No title...")
                        
                        if status == .read { Text("Read at: \(chapter.readAt?.formatted() ?? "No date...")") }
                        if status == .all { Text("Uploaded at: \(chapter.dateSourceUpload?.formatted() ?? "No date...")") }
                    }
                }
                .frame(minHeight: 120)
            }
        )
    }
}
