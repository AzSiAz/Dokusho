//
//  MangaCollectionPage.swift
//  Dokusho
//
//  Created by Stephan Deumier on 02/07/2021.
//

import SwiftUI

struct MangaCollectionPage: View {
    var srcSVC = MangaSourceService.shared

    var vm: LibraryVM
    var collection: Binding<MangaCollection>
    
    var columns: [GridItem] {
        var base = [
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible()),
        ]
        
        if UIDevice.current.userInterfaceIdiom == .pad || UIDevice.current.userInterfaceIdiom == .mac {
            base = [GridItem(.adaptive(minimum: 180, maximum: 180))]
        }
        
        return base
    }
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(vm.getMangas(collection: collection.wrappedValue)) { manga in
                    NavigationLink(destination: MangaDetailView(vm: MangaDetailVM(for: srcSVC.getSource(sourceId: manga.source)!, mangaId: manga.id!))) {
                        ImageWithTextOver(title: manga.title!, imageUrl: manga.cover!)
                            .frame(height: 180)
                            .overlay(alignment: .topTrailing) {
                                MangaUnreadCount(manga: manga)
                            }
                            .contextMenu {
                                if manga.unreadChapterCount() != 0 {
                                    Button(action: { vm.markChaptersMangaAs(for: manga, status: .read) }) {
                                        Text("Mark as read")
                                    }
                                }
                                
                                if manga.unreadChapterCount() == 0 {
                                    Button(action: { vm.markChaptersMangaAs(for: manga, status: .unread) }) {
                                        Text("Mark as unread")
                                    }
                                }
                            }
                    }
                }
            }
        }
    }
}
