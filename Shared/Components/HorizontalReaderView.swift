//
//  HorizontalReaderView.swift
//  Dokusho (iOS)
//
//  Created by Stephan Deumier on 15/06/2021.
//

import SwiftUI
import Pages
import NukeUI

enum ReadingDirection {
    case rightToLeft
    case leftToRight
}

struct HorizontalReaderView: View {
    @State var index = 0
    @GestureState var scale: CGFloat = 1.0
    
    var links: [String]
    
    init(direction: ReadingDirection, links: [String]) {
        self.links = links
        if direction == .rightToLeft {
            self.links = links.reversed()
            self._index = .init(initialValue: self.links.count - 1)
        }
    }

    var body: some View {
        ModelPages(
            links,
            currentPage: $index,
            navigationOrientation: .horizontal,
            hasControl: false)
        { _, image in
            GeometryReader { proxy in
                LazyImage(source: image)
                    .placeholder {
                        ProgressView()
                    }
                    .contentMode(.aspectFit)
                    .frame(minWidth: proxy.size.width, minHeight: proxy.size.height)
            }
        }
    }
}

struct HorizontalReaderView_Previews: PreviewProvider {
    static var previews: some View {
        HorizontalReaderView(direction: .leftToRight, links: [""])
    }
}
