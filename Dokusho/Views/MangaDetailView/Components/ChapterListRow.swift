//
//  ChapterListRow.swift
//  Dokusho (iOS)
//
//  Created by Stephan Deumier on 26/06/2021.
//

import SwiftUI

struct ChapterListRow: View {
    @ObservedObject var vm: ChapterListVM
    @Binding var selectedChapter: MangaChapter?

    var chapter: MangaChapter
    
    var body: some View {
        HStack {
            Button(action: { selectedChapter = chapter }) {
                HStack {
                    VStack(alignment: .leading) {
                        Text(chapter.title)
                        Text(chapter.dateSourceUpload.formatted())
                            .font(.system(size: 12))
                        if let readAt = chapter.readAt {
                            Text("Read At: \(readAt.formatted())")
                                .font(.system(size: 10))
                        }
                    }
                }
                
                Spacer()
                
                Button(action: { print("download")}) {
                    Image(systemName: "icloud.and.arrow.down")
                }
            }
            .buttonStyle(.plain)
            .padding(.vertical, 5)
        }
        .foregroundColor(chapter.status == .read ? Color.gray : Color.blue)
    }
}
