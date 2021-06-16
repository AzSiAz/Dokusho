//
//  ImageWithTextOver.swift
//  Dokusho
//
//  Created by Stephan Deumier on 06/06/2021.
//

import SwiftUI
import NukeUI

struct ImageWithTextOver: View {
    var title: String
    var imageUrl: String
    
    var body: some View {
        GeometryReader { proxy in
            LazyImage(source: imageUrl) { state in
                if state.isLoading {
                    ProgressView()
                }
                if let image = state.image {
                    image
                        .resizingMode(.aspectFill)
                }
            }
            .frame(width: proxy.size.width, height: proxy.size.height, alignment: .bottomLeading)
            .animation(.none, value: 1)
            .overlay(
                ZStack {
                    Text(title)
                        .lineLimit(2)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.leading)
                        .clipped()
                }
                    .frame(width: proxy.size.width)
                .background(Color(.systemGray).opacity(0.8))
                , alignment: .bottomLeading)
            .cornerRadius(10)
        }
    }
}

struct ImageWithTextOver_Previews: PreviewProvider {
    static var previews: some View {
        ImageWithTextOver(title: "Ookii Kouhai wa Suki Desu ka", imageUrl: "https://cover.nep.li/cover/Ookii-Kouhai-wa-Suki-Desu-ka.jpg")
            .frame(width: 150, height: 180)
    }
}
