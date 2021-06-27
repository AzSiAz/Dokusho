//
//  HorizontalReaderView.swift
//  Dokusho (iOS)
//
//  Created by Stephan Deumier on 15/06/2021.
//

import SwiftUI
import NukeUI
import iPages

enum ReadingDirection {
    case rightToLeft
    case leftToRight
}

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
                        .onAppear {
                            if direction == .leftToRight { sliderProgress = Double(links.firstIndex(of: link) ?? 0) + 1 }
                            else { sliderProgress = Double(links.reversed().firstIndex(of: link) ?? 0) + 1 }
                        }
                }
            }
        }
        .hideDots(true)
        .onChange(of: index, perform: { newValue in
            var status: MangaChapter.Status = .reading
            
            if direction == .leftToRight && newValue == links.count - 1 {
                status = .read
            }
            else if direction == .rightToLeft && newValue == 0 {
                status = .read
            }
            
            self.onProgress(status)
        })
    }
}

struct HorizontalReaderView_Previews: PreviewProvider {
    static var previews: some View {
        HorizontalReaderView(direction: .leftToRight, links: [""], showToolbar: .constant(true), sliderProgress: .constant(0)) { status in
            print(status)
        }
    }
}
