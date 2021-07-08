//
//  VerticalReaderView.swift
//  Dokusho (iOS)
//
//  Created by Stephan Deumier on 16/06/2021.
//

import SwiftUI
import NukeUI
import iPages

struct VerticalReaderView: View {
    @Binding var showToolbar: Bool
    @Binding var sliderProgress: Double
    
    let links: [String]
    let onProgress: OnProgress
    
    var body: some View {
        GeometryReader { proxy in
            ScrollView([.vertical]) {
                LazyVStack(spacing: 0) {
                    ForEach(links, id: \.self) { link in
                        RefreshableImageView(url: link, size: CGSize(width: proxy.size.width, height: UIScreen.main.bounds.height))
                            .aspectRatio(contentMode: .fit)
                            .frame(width: proxy.size.width)
                            .id(links.firstIndex(of: link))
                            .onAppear { updateProgressBar(link: link) }
                            .background(Color.black)
                    }
                    LazyVStack {
                        Color.clear
                            .onAppear { onProgress(.read) }
                    }
                }
            }
        }
    }
    
    func updateProgressBar(link: String) {
        sliderProgress = Double(links.firstIndex { $0 == link } ?? 0) + 1
    }
}
