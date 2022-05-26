//
//  HistoryTabView.swift
//  HistoryTabView
//
//  Created by Stephan Deumier on 12/09/2021.
//

import SwiftUI
import GRDBQuery
import Combine
import DataKit
import SharedUI
import MangaDetail

struct HistoryTabView: View {
    @Query(ChaptersHistoryRequest(filter: .read, searchTerm: "")) var list: [ChaptersHistory]

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
            .listStyle(PlainListStyle())
            .id($list.filter.wrappedValue)
            .searchable(text: $list.searchTerm)
            .navigationBarTitle($list.filter.wrappedValue == .read ? "Reading history" : "Update history", displayMode: .large)
        }
        .navigationViewStyle(.columns)
    }
    
    @ViewBuilder
    func ChapterRow(_ data: ChaptersHistory) -> some View {
        NavigationLink(destination: MangaDetail(mangaId: data.manga.mangaId, scraper: data.scraper)) {
            HStack {
                MangaCard(imageUrl: data.manga.cover.absoluteString)
                    .mangaCardFrame(width: 80, height: 120)
                    .id(data.id)

                VStack(alignment: .leading) {
                    Text(data.manga.title)
                        .lineLimit(2)
                    Text(data.chapter.title)
                        .lineLimit(1)
                    
                    if $list.filter.wrappedValue == .read { Text("Read at: \(data.chapter.readAt?.formatted() ?? "No date...")") }
                    if $list.filter.wrappedValue == .all { Text("Uploaded at: \(data.chapter.dateSourceUpload.formatted())") }
                }
            }
            .frame(height: 120)
        }
    }
}
