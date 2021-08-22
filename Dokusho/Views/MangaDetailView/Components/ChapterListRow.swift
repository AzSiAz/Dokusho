//
//  ChapterListRow.swift
//  Dokusho (iOS)
//
//  Created by Stephan Deumier on 26/06/2021.
//

import SwiftUI

struct ChapterListRow: View {
    @ObservedObject var vm: ChapterListVM
    @ObservedObject var chapter: ChapterEntity
    
    @Binding var selectedChapter: ChapterEntity?
    
    var body: some View {
        HStack {
            Button(action: { selectedChapter = chapter }) {
                HStack {
                    VStack(alignment: .leading) {
                        Text(chapter.title ?? "")
                        Text(chapter.dateSourceUpload?.formatted() ?? "")
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
        .foregroundColor(chapter.statusRaw == ChapterStatus.read.rawValue ? Color.gray : Color.blue)
    }
}