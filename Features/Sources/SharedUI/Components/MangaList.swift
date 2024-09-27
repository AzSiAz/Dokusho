//
//  File.swift
//  
//
//  Created by Stephan Deumier on 04/06/2022.
//

import Foundation
import SwiftUI

public struct MangaList<MangaContent: View, T: Identifiable, Y: RandomAccessCollection<T>>: View {
    var mangas: Y
    var mangaContent: (T) -> MangaContent
    
    var columns: [GridItem] {
        let size: Double = UIScreen.isLargeScreen ? 130*1.3 : 130
        return [GridItem(.adaptive(minimum: size))]
    }
    
    public init(mangas: Y, @ViewBuilder mangaRender: @escaping (T) -> MangaContent) {
        self.mangas = mangas
        self.mangaContent = mangaRender
    }
    
    public var body: some View {
        LazyVGrid(columns: columns) {
            ForEach(mangas) { data in
                mangaContent(data)
            }
        }
    }
}
