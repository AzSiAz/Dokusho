//
//  HistoryTabView.swift
//  HistoryTabView
//
//  Created by Stephan Deumier on 12/09/2021.
//

import SwiftUI
import GRDBQuery
import Combine

struct HistoryTabView: View {
    @Query(ChaptersHistoryRequest(filter: .read, searchTerm: "")) var list: [ChaptersHistory]
    
    @State var searchTitle: String = ""
    
    var body: some View {
        NavigationView {
            List {
                ForEach(list) { data in
                    ChapterRow(data)
                }
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Picker("Chapter Status", selection: $list.filter) {
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
            .id($list.filter.wrappedValue)
            .listStyle(.plain)
            .searchable(text: $list.searchTerm)
            .navigationBarTitle($list.filter.wrappedValue == .read ? "Reading history" : "Update history", displayMode: .large)
            .mirrorAppearanceState(to: $list.isAutoupdating)
        }
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
                    
                    if $list.filter.wrappedValue == .read { Text("Read at: \(data.chapter.readAt?.formatted() ?? "No date...")") }
                    if $list.filter.wrappedValue == .all { Text("Uploaded at: \(data.chapter.dateSourceUpload.formatted())") }
                }
            }
            .frame(minHeight: 120)
        }
    }
}
