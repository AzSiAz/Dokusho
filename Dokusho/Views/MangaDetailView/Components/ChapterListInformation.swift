//
//  ChapterList.swift
//  Dokusho
//
//  Created by Stephan Deumier on 04/07/2021.
//

import SwiftUI

struct ChapterListInformation: View {
    @ObservedObject var manga: MangaEntity
    
    @Binding var selectedChapter: ChapterEntity?
    @State var ascendingOrder = true
    @State var filter: ChapterStatusFilter = .all
    var refreshing: Bool

    var body: some View {
        LazyVStack {
            HStack {
                Text("Chapter List")
                    .font(.title3)
                
                Spacer()
                
                HStack {
                    Button(action: { filter.toggle() }) {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                            .resizable()
                            .scaledToFit()
                            .symbolVariant(filter == .all ? .none : .fill)
                    }
                    .padding(.trailing, 5)
                    
                    Button(action: { ascendingOrder.toggle() }) {
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
            
            ChapterCollection(manga: manga.objectID, selectedChaper: $selectedChapter, ascendingOrder: ascendingOrder, filter: filter, refreshing: refreshing)
                .padding(.horizontal, 10)
        }
    }
}
