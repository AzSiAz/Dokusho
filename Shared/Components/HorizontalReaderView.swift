//
//  HorizontalReaderView.swift
//  Dokusho (iOS)
//
//  Created by Stephan Deumier on 15/06/2021.
//

import SwiftUI
import NukeUI

struct HorizontalReaderView: View {
    @State var index: String
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
            self._index = .init(wrappedValue: self.links.last!)
        }
        else {
            self._index = .init(wrappedValue: self.links.first!)
        }
    }

    var body: some View {
        TabView(selection: $index) {
            ForEach(self.links, id: \.self) { link in
                GeometryReader { proxy in
                    RefreshableImageView(url: link, size: proxy.size)
                        .aspectRatio(contentMode: .fit)
                        .frame(minWidth: UIScreen.isLargeScreen() ? proxy.size.width / 2: proxy.size.width, minHeight: proxy.size.height)
                        .background(Color.black)
                        .tag(link)
                }
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .onChange(of: index, perform: { newValue in
            updateProgressBar(link: newValue)
            updateChapterStatus(link: newValue)
        })
        .background(Color.black)
    }
    
    func updateProgressBar(link: String) {
        if direction == .leftToRight { sliderProgress = Double(links.firstIndex(of: link) ?? 0) + 1 }
        else { sliderProgress = Double(links.reversed().firstIndex(of: link) ?? 0) + 1 }
    }
    
    func updateChapterStatus(link: String) {
        if direction == .leftToRight && link == links.last {
            let status: MangaChapter.Status = .read
            self.onProgress(status)
        }
        else if direction == .rightToLeft && link == links.first {
            let status: MangaChapter.Status = .read
            self.onProgress(status)
        }
    }
}
