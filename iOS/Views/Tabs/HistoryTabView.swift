//
//  HistoryTabView.swift
//  Dokusho
//
//  Created by Stephan Deumier on 06/07/2021.
//

import SwiftUI
import NukeUI

struct HistoryTabView: View {
    @EnvironmentObject var sourcesSvc: MangaSourceService
    
    private var dataManager = DataManager.shared
    
    @FetchRequest(fetchRequest: MangaChapter.fetchChaptersHistory()) var chapters: FetchedResults<MangaChapter>
    @State var selectedManga: Manga?
    
    var body: some View {
        NavigationView {
            List {
                ForEach(chapters, id: \.self) { chapter in
                    HStack {
                        RemoteImageCacheView(url: try! chapter.manga!.cover!.asURL(), contentMode: .fit)
                            .frame(width: 80)
                            .onTapGesture { selectedManga = chapter.manga }
                        
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
            .sheetSizeAware(item: $selectedManga) { manga in
                MangaDetailView(vm: .init(for: sourcesSvc.getSource(sourceId: manga.source)!, mangaId: manga.id!))
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
