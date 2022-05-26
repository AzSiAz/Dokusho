//
//  SwiftUIView.swift
//  
//
//  Created by Stephan Deumier on 26/05/2022.
//

import SwiftUI
import SwiftUIX

public struct MangaCard: View {
    var imageUrl: String

    var title: String?
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
    
    public init(imageUrl: String) {
        self.imageUrl = imageUrl
    }
    
    public var body: some View {
        GeometryReader { proxy in
            RemoteImageCacheView(url: self.imageUrl, contentMode: .fill, radius: radius)
                .frame(minWidth: proxy.size.width, minHeight: proxy.size.height, alignment: .center)
                .overlay(alignment: .bottomLeading) { OverlayTitle(width: proxy.size.width) }
                .overlay(alignment: .topTrailing) { ChapterCounter() }
                .overlay(alignment: .topLeading) { CollectionName() }
                .overlay(
                    RoundedRectangle(cornerRadius: radius)
                        .stroke(.gray, lineWidth: 0.2)
                )
                .removeIfNotInDisplay()
        }
    }
    
    @ViewBuilder
    func OverlayTitle(width: Double) -> some View {
        if let title = title, !title.isEmpty {
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
            .clipShape(RoundedCorner(radius: radius, corners: [.bottomRight, .bottomLeft]))
        }
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
    func mangaCardFrame(width: Double = 130, height: Double = 180) -> some View {
        return self
            .frame(width: width, height: height)
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
