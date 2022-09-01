//
//  SwiftUIView.swift
//  
//
//  Created by Stephan Deumier on 26/05/2022.
//

import SwiftUI

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
    
    public init(imageUrl: String, chapterCount: Int) {
        self.imageUrl = imageUrl
        self.chapterCount = chapterCount
    }
    
    public init(imageUrl: String) {
        self.imageUrl = imageUrl
    }
    
    public var body: some View {
//        VStack {
            RemoteImageCacheView(url: self.imageUrl, contentMode: .fill)
                .clipShape(RoundedCorner(radius: radius, corners: [.allCorners]))
                .overlay(alignment: .topTrailing) { ChapterCounter() }
                .overlay(alignment: .topLeading) { CollectionName() }
                .overlay(alignment: .bottomLeading) { Title() }
//            Title()
//        }
    }
    
    @ViewBuilder
    func Title() -> some View {
        if let title = title, !title.isEmpty {
            Text(title)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
                .clipped()
                .padding(.leading, 2)
                .padding(.top, 1)
                .frame(maxWidth: .infinity, alignment: .center)
                .foregroundColor(.white)
                .background(Color.darkGray.opacity(0.7), in: RoundedCorner(radius: radius, corners: [.bottomRight, .bottomLeft]))
                .fixedSize(horizontal: false, vertical: true)
        }
    }
    
    @ViewBuilder
    func ChapterCounter() -> some View {
        if let count = chapterCount, count != 0  {
            Text(String(count))
                .padding(2)
                .foregroundColor(.white)
                .background(Color.darkGray.opacity(0.7), in: RoundedCorner(radius: radius, corners: [.topRight, .bottomLeft]))
        }
    }
    
    @ViewBuilder
    func CollectionName() -> some View {
        if let collectionName = collectionName, !collectionName.isEmpty {
            Text(collectionName)
                .lineLimit(1)
                .padding(2)
                .foregroundColor(.white)
                .background(Color.darkGray.opacity(0.7), in: RoundedCorner(radius: radius, corners: [.topLeft, .bottomRight]) )
        }
    }
}

public extension View {
    func mangaCardFrame(width: Double = 130, height: Double = 180) -> some View {
        if width != 130 || height != 180 {
            return self
                .frame(width: width, height: height)
        } else if UIScreen.isLargeScreen {
            return self
                .frame(width: 130*1.3, height: 180*1.3)
        } else {
            return self
                .frame(width: 130, height: 180)
        }
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
