//
//  ImageWithTextOver.swift
//  Dokusho
//
//  Created by Stephan Deumier on 06/06/2021.
//

import SwiftUI

struct ImageWithTextOver: View {
    var title: String
    var imageUrl: String
    var radius: Double = 10
    
    var body: some View {
        GeometryReader { proxy in
            RemoteImageCacheView(url: imageUrl, contentMode: .fill, radius: radius)
                .frame(minWidth: proxy.size.width, minHeight: proxy.size.height, alignment: .bottomLeading)
                .overlay(alignment: .bottomLeading) {
                    ZStack {
                        Text(title)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                            .clipped()
                        }
                        .frame(width: proxy.size.width)
                        .background(.ultraThinMaterial)
                }
                .cornerRadius(radius)
        }
    }
}

struct ImageWithTextOver_Previews: PreviewProvider {
    static var previews: some View {
        ImageWithTextOver(title: "Ookii Kouhai wa Suki Desu ka", imageUrl: "https://cover.nep.li/cover/Ookii-Kouhai-wa-Suki-Desu-ka.jpg")
            .frame(width: 150, height: 180)
    }
}
