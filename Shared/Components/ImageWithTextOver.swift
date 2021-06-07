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
        LazyImage(source: imageUrl)
            .placeholder {
                ProgressView()
            }
            .contentMode(.aspectFill)
            .overlay(
                ZStack(alignment: .bottomLeading) {
                    Text(title)
                        .lineLimit(2)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.leading)
                        .clipped()
                }
                .frame(maxWidth: .infinity)
                .background(Color(.systemGray).opacity(0.8))
                , alignment: .bottomLeading)
            .cornerRadius(10)
    }
}

struct ImageWithTextOver_Previews: PreviewProvider {
    static var previews: some View {
        ImageWithTextOver(title: "Ookii Kouhai wa Suki Desu ka", imageUrl: "https://cover.nep.li/cover/Ookii-Kouhai-wa-Suki-Desu-ka.jpg")
    }
}
