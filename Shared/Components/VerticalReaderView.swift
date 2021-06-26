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
    
    let links: [String]
    let onProgress: OnProgress
    
    var body: some View {
        GeometryReader { proxy in
            ScrollView([.vertical]) {
                VStack(spacing: 0) {
                    ForEach(links, id: \.self) { link in
                        RefreshableImageView(url: link, size: CGSize(width: proxy.size.width, height: UIScreen.main.bounds.height))
                            .aspectRatio(contentMode: .fit)
                            .frame(width: proxy.size.width)
                    }
                    LazyVStack {
                        Color.clear
                            .onAppear { onProgress(.read) }
                    }
                }
            }
        }
    }
}
