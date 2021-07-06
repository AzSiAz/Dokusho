//
//  HorizontalReaderView.swift
//  Dokusho (iOS)
//
//  Created by Stephan Deumier on 15/06/2021.
//

import SwiftUI
import NukeUI
import iPages

struct HorizontalReaderView: View {    
    @State var index = 0
    @GestureState var scale: CGFloat = 1.0
    @Binding var showToolbar: Bool
    @Binding var sliderProgress: Double
    
    var links: [String]
    var onProgress: OnProgress
    var direction: ReadingDirection
    
    init(direction: ReadingDirection, links: [String], showToolbar: Binding<Bool>, sliderProgress: Binding<Double>, onProgress: @escaping OnProgress) {
        self.links = links
        self._showToolbar = showToolbar
        self.onProgress = onProgress
        self.direction = direction
        self._sliderProgress = sliderProgress
        
        if direction == .rightToLeft {
            self.links = links.reversed()
            self._index = .init(initialValue: self.links.count - 1)
        }
    }

    var body: some View {
        iPages(selection: $index) {
            ForEach(self.links, id: \.self) { link in
                GeometryReader { proxy in
                    RefreshableImageView(url: link, size: proxy.size)
                        .aspectRatio(contentMode: .fit)
                        .frame(minWidth: proxy.size.width, minHeight: proxy.size.height)
                }
            }
        }
        .hideDots(true)
        .onChange(of: index, perform: { newValue in
            updateProgressBar(index: newValue)
            updateChapterStatus(index: newValue)
        })
    }
    
    func updateProgressBar(index: Int) {
        if direction == .leftToRight { sliderProgress = Double(links.firstIndex(of: links[index]) ?? 0) + 1 }
        else { sliderProgress = Double(links.reversed().firstIndex(of: links[index]) ?? 0) + 1 }
    }
    
    func updateChapterStatus(index: Int) {
        var status: MangaChapter.Status = .unread
        
        if direction == .leftToRight && index == links.count - 1 {
            status = .read
        }
        else if direction == .rightToLeft && index == 0 {
            status = .read
        }
        
        self.onProgress(status)
    }
}
