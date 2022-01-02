//
//  ChapterList.swift
//  Dokusho
//
//  Created by Stephan Deumier on 04/07/2021.
//

import SwiftUI

struct ChapterListInformation: View {
    @State var ascendingOrder = true
    @State var filter: ChapterStatusFilter = .all
    
    var manga: Manga
    var scraper: Scraper

    var body: some View {
        LazyVStack {
            HStack {
                Text("Chapter List")
                    .font(.title3)
                
                Spacer()
                
                HStack {
                    Button(action: { filter.toggle() }) {
                        Image(systemSymbol: .lineHorizontal3DecreaseCircle)
                            .resizable()
                            .scaledToFit()
                            .symbolVariant(filter == .all ? .none : .fill)
                    }
                    .padding(.trailing, 5)
                    
                    Button(action: { ascendingOrder.toggle() }) {
                        Image(systemSymbol: .chevronUpChevronDown)
                            .resizable()
                            .scaledToFit()
                    }
                }
            }
            .frame(height: 24)
            .padding(.vertical, 10)
            .padding(.horizontal, 15)
            
            ChapterCollection(manga: manga, scraper: scraper, ascendingOrder: ascendingOrder, filter: filter)
                .padding(.horizontal, 10)
        }
    }
}
