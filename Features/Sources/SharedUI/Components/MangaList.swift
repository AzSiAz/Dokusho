//
//  File.swift
//  
//
//  Created by Stephan Deumier on 04/06/2022.
//

import Foundation
import SwiftUI

public struct MangaList<MangaContent: View, T: Identifiable>: View {
    var mangas: [T]
    var mangaContent: (T) -> MangaContent
    
    var columns: [GridItem] {
        let size: Double = UIScreen.isLargeScreen ? 130*1.3 : 130
        return [GridItem(.adaptive(size))]
    }
    
    public init(mangas: [T], @ViewBuilder mangaRender: @escaping (T) -> MangaContent) {
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
