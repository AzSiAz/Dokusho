//
//  ChapterList.swift
//  Dokusho
//
//  Created by Stephan Deumier on 04/07/2021.
//

import SwiftUI

struct ChapterListView: View {
    @StateObject var vm: ChapterListVM
    
    var body: some View {
        LazyVStack {
            if let chapter = vm.nextUnreadChapter() {
                Button(action: { vm.selectChapter(for: chapter) }) {
                    Text("Read next unread chapter")
                        .frame(minWidth: 0, maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
                .padding(.horizontal)
            }

            HStack {
                Text("Chapter List")
                
                Spacer()
                
                Button(action: { vm.toggleFilter() }) {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                        .symbolVariant(vm.filter == .all ? .none : .fill)
                }
                .padding(.trailing, 5)
                
                Button(action: { vm.toggleOrder() }) {
                    Image(systemName: "chevron.up.chevron.down")
                }
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 15)
            
            ForEach(vm.chapters) { chapter in
                ChapterListRow(vm: vm, chapter: chapter)
            }
            .padding(.horizontal, 10)
        }
        .task { vm.fetchCollection() }
        .fullScreenCover(item: $vm.selectedChapter) { chapter in
            ReaderView(vm: .init(for: chapter))
        }
    }
}

struct ChapterList_Previews: PreviewProvider {
    static var previews: some View {
        ChapterListView(vm: .init(mangaId: "Solo-Leveling", filter: .all))
    }
}
