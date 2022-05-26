//
//  SwiftUIView.swift
//  
//
//  Created by Stephan Deumier on 26/05/2022.
//

import SwiftUI

public struct MangaCard: View {
    var title: String
    var imageUrl: String

    var chapterCount: Int?
    var collectionName: String?
    
    var radius: Double = 5
    
    public init(title: String, imageUrl: String, chapterCount: Int) {
        self.title = title
        self.chapterCount = chapterCount
        self.imageUrl = imageUrl
    }
    
    public init(title: String, imageUrl: String, collectionName: String) {
        self.title = title
        self.collectionName = collectionName
        self.imageUrl = imageUrl
    }
    
    public init(title: String, imageUrl: String) {
        self.title = title
        self.imageUrl = imageUrl
    }
    
    public var body: some View {
        GeometryReader { proxy in
            RemoteImageCacheView(url: self.imageUrl, contentMode: .fill, radius: radius)
                .frame(minWidth: proxy.size.width, minHeight: proxy.size.height, alignment: .center)
                .overlay(alignment: .bottomLeading) { OverlayTitle(width: proxy.size.width) }
                .overlay(alignment: .topTrailing) { ChapterCounter() }
                .overlay(alignment: .topLeading) { CollectionName() }
                .cornerRadius(radius)
        }
    }
    
    @ViewBuilder
    func OverlayTitle(width: Double) -> some View {
        VStack {
            Text(title)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
                .clipped()
                .padding(.leading, 2)
                .padding(.top, 1)
        }
        .frame(width: width)
        .background(.ultraThinMaterial)
    }
    
    @ViewBuilder
    func ChapterCounter() -> some View {
        if let count = chapterCount, count != 0  {
            Text(String(count))
                .padding(2)
                .foregroundColor(.primary)
                .background(.thinMaterial, in: RoundedCorner(radius: radius, corners: [.topRight, .bottomLeft]))
                .clipShape(RoundedCorner(radius: radius, corners: [.topRight, .bottomLeft]))
        }
    }
    
    @ViewBuilder
    func CollectionName() -> some View {
        if let collectionName = collectionName, !collectionName.isEmpty {
            Text(collectionName)
                .lineLimit(1)
                .padding(2)
                .foregroundColor(.primary)
                .background(.thinMaterial, in: RoundedCorner(radius: radius, corners: [.topLeft, .bottomRight]) )
        }
    }
}

public extension View {
    func mangaCardFrame() -> some View {
        return self
            .frame(width: 130, height: 180)
    }
}

struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        MangaCard(title: "Ookii Kouhai wa Suki Desu ka", imageUrl: "https://cover.nep.li/cover/Ookii-Kouhai-wa-Suki-Desu-ka.jpg", collectionName: "Reading")
            .mangaCardFrame()
        
        MangaCard(title: "Ookii Kouhai wa Suki Desu ka", imageUrl: "https://cover.nep.li/cover/Ookii-Kouhai-wa-Suki-Desu-ka.jpg", chapterCount: 5)
            .mangaCardFrame()
    }
}
