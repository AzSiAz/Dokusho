//
//  ChapterList.swift
//  Dokusho
//
//  Created by Stephan Deumier on 04/07/2021.
//

import SwiftUI

struct ChapterListView: View {
    @StateObject var vm: ChapterListVM
    @Binding var selectedChapter: MangaChapter?
    
    var body: some View {
        LazyVStack {
            if let chapter = vm.nextUnreadChapter() {
                Button(action: { selectedChapter = chapter }) {
                    Text("Read next unread chapter")
                        .frame(minWidth: 0, maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
                .padding(.horizontal)
            }

            HStack {
                Text("Chapter List")
                    .font(.title3)
                
                Spacer()
                
                HStack {
                    Button(action: { vm.toggleFilter() }) {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                            .resizable()
                            .scaledToFit()
                            .symbolVariant(vm.filter == .all ? .none : .fill)
                    }
                    .padding(.trailing, 5)
                    
                    Button(action: { vm.toggleOrder() }) {
                        Image(systemName: "chevron.up.chevron.down")
                            .resizable()
                            .scaledToFit()
                    }
                }
            }
            .frame(height: 24)
            .padding(.vertical, 10)
            .padding(.horizontal, 15)
            
            Divider()
                .padding(.horizontal, 5)
            
            ForEach(vm.chapters) { chapter in
                ChapterListRow(vm: vm, selectedChapter: $selectedChapter, chapter: chapter)
                    .padding(.vertical, 3)
            }
            .padding(.horizontal, 10)
        }
        .task { vm.fetchCollection() }
    }
}
