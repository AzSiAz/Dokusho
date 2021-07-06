//
//  HistoryTabView.swift
//  Dokusho
//
//  Created by Stephan Deumier on 06/07/2021.
//

import SwiftUI
import NukeUI

struct HistoryTabView: View {
    private var dataManager = DataManager.shared
    @FetchRequest(fetchRequest: MangaChapter.fetchChaptersHistory()) var chapters: FetchedResults<MangaChapter>
    
    var body: some View {
        NavigationView {
            List {
                ForEach(chapters, id: \.self) { chapter in
                    HStack {
                        RemoteImageCacheView(url: try! chapter.manga!.cover!.asURL(), contentMode: .fit)
                            .frame(width: 80)
                        
                        VStack(alignment: .leading) {
                            Text(chapter.manga!.title!)
                            Text(chapter.title ?? "No title...")
                            Text(chapter.readAt?.formatted() ?? "No date...")
                        }
                    }
                    .frame(height: 120, alignment: .leading)
                }
                .onDelete { dataManager.markChapterAs(chapter: chapters[$0.first!], status: .unread) }
            }
            .toolbar { EditButton() }
            .listStyle(.plain)
            .navigationBarTitle("Reading History", displayMode: .large)
        }
        .navigationViewStyle(.stack)
    }
}

struct HistoryTabView_Previews: PreviewProvider {
    static var previews: some View {
        HistoryTabView()
    }
}
