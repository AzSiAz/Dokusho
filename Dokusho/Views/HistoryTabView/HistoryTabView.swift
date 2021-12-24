//
//  HistoryTabView.swift
//  HistoryTabView
//
//  Created by Stephan Deumier on 12/09/2021.
//

import SwiftUI
import GRDBQuery

struct HistoryTabView: View {
    @State var searchTitle: String = ""
    @State var status: ChapterStatusHistory = .read
    
    var body: some View {
        NavigationView {
            FilteredHistoryView(searchTitle: searchTitle, status: status)
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
    @Query<ChaptersHistoryRequest> var list: [ChaptersHistory]
    var status: ChapterStatusHistory
    
    init(searchTitle: String, status: ChapterStatusHistory) {
        self.status = status
        _list = Query(ChaptersHistoryRequest(filter: status, searchTerm: searchTitle))
    }
    
    var body: some View {
        List {
            ForEach(list) { data in
                ChapterRow(data)
            }
        }
        .id(UUID())
    }
    
    @ViewBuilder
    func ChapterRow(_ data: ChaptersHistory) -> some View {
        NavigationLink(destination: MangaDetailView(mangaId: data.manga.mangaId, scraper: data.scraper, showDismiss: false)) {
            HStack {
                RemoteImageCacheView(url: data.manga.cover, contentMode: .fit)
                    .frame(width: 80)
                    .id(data.id)
                
                VStack(alignment: .leading) {
                    Text(data.manga.title)
                    Text(data.chapter.title)
                    
                    if status == .read { Text("Read at: \(data.chapter.readAt?.formatted() ?? "No date...")") }
                    if status == .all { Text("Uploaded at: \(data.chapter.dateSourceUpload.formatted())") }
                }
            }
            .frame(minHeight: 120)
        }
    }
}
