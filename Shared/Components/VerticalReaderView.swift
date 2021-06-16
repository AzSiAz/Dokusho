//
//  VerticalReaderView.swift
//  Dokusho (iOS)
//
//  Created by Stephan Deumier on 16/06/2021.
//

import SwiftUI
import NukeUI

struct VerticalReaderView: View {
//    @State var imagesSize: [String: CGSize] = [:]
    
    let links: [String]
    
    var body: some View {
        GeometryReader { proxy in
            ScrollView([.vertical]) {
                VStack(spacing: 0) {
                    ForEach(links, id: \.self) { link in
                        LazyImage(source: link) { state in
                            if state.isLoading {
                                ProgressView()
                            }
                            
                            if let image = state.image {
                                image.resizingMode(.aspectFit)
                            }
                        }
                        .animation(nil)
//                        .onSuccess({ imagesSize[link] = $0.image.size })
                        .frame(width: proxy.size.width)
//                        .frame(height: imagesSize[link]?.height ?? 0)
                    }
                }
            }
        }
    }
}

struct VerticalReaderView_Previews: PreviewProvider {
    static var previews: some View {
        VerticalReaderView(links: [""])
    }
}
