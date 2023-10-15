//
//  SwiftUIView.swift
//  
//
//  Created by Stephan Deumier on 26/05/2022.
//

import SwiftUI

public struct SerieCard: View {
    var imageUrl: URL

    var title: String?
    var chapterCount: Int?
    var collectionName: String?
    
    var radius: Double = 5
    var opacity: Double = 0.83
    
    public init(title: String, imageUrl: URL?, chapterCount: Int) {
        self.title = title
        self.chapterCount = chapterCount
        self.imageUrl = imageUrl ?? URL(string: "https://picsum.photos/seed/picsum/200/300")!
    }
    
    public init(title: String, imageUrl: URL?, collectionName: String? = nil) {
        self.title = title
        self.collectionName = collectionName
        self.imageUrl = imageUrl ?? URL(string: "https://picsum.photos/seed/picsum/200/300")!
    }
    
    public init(imageUrl: URL?, chapterCount: Int) {
        self.imageUrl = imageUrl ?? URL(string: "https://picsum.photos/seed/picsum/200/300")!
        self.chapterCount = chapterCount
    }
    
    public init(imageUrl: URL?) {
        self.imageUrl = imageUrl ?? URL(string: "https://picsum.photos/seed/picsum/200/300")!
    }
    
    public var body: some View {
        RemoteImageCacheView(url: self.imageUrl, contentMode: .fill)
            .clipShape(RoundedCorner(radius: radius, corners: [.allCorners]))
            .overlay(alignment: .topTrailing) { ChapterCounter }
            .overlay(alignment: .topLeading) { CollectionName }
            .overlay(alignment: .bottomLeading) { Title }
            .mangaCardFrame()
    }
    
    @ViewBuilder
    var Title: some View {
        if let title = title, !title.isEmpty {
            VStack {
                Text(title)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                    .clipped()
                    .padding(.leading, 2)
                    .padding(.top, 1)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .foregroundColor(.white)
                    .background(Color.darkGray.opacity(opacity), in: RoundedCorner(radius: radius, corners: [.allCorners]))
            }
            .padding(2)
        }
    }
    
    @ViewBuilder
    var ChapterCounter: some View {
        if let count = chapterCount, count != 0  {
            VStack {
                Text(String(count))
                    .padding(2)
                    .foregroundColor(.white)
                    .background(Color.darkGray.opacity(opacity), in: RoundedCorner(radius: radius, corners: [.allCorners]))
            }
            .padding(2)
        }
    }
    
    @ViewBuilder
    var CollectionName: some View {
        if let collectionName = collectionName, !collectionName.isEmpty {
            VStack {
                Text(collectionName)
                    .lineLimit(1)
                    .padding(2)
                    .foregroundColor(.white)
                    .background(Color.darkGray.opacity(opacity), in: RoundedCorner(radius: radius, corners: [.allCorners]) )
            }
            .padding(2)
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
    
    func mangaCardHeight(height: Double = 180) -> some View {
        if height != 180 {
            return self
                .frame(height: height)
        } else if UIScreen.isLargeScreen {
            return self
                .frame(height: 180*1.3)
        } else {
            return self
                .frame(height: 180)
        }
    }
}

#Preview {
    Group {
        SerieCard(title: "Ookii Kouhai wa Suki Desu ka", imageUrl: URL(string: "https://cover.nep.li/cover/Ookii-Kouhai-wa-Suki-Desu-ka.jpg")!, collectionName: "Reading")
            .mangaCardFrame()
        
        SerieCard(title: "Ookii Kouhai wa Suki Desu ka", imageUrl: URL(string: "https://cover.nep.li/cover/Ookii-Kouhai-wa-Suki-Desu-ka.jpg")!, chapterCount: 5)
            .mangaCardFrame()
    }
}