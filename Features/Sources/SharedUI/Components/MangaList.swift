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
    var horizontal: Bool
    
    var columns: [GridItem] {
        let size: Double = UIScreen.isLargeScreen ? 130*1.3 : 130
        return [GridItem(.adaptive(size))]
    }
    
    public init(mangas: Y, horizontal: Bool = false, @ViewBuilder mangaRender: @escaping (T) -> MangaContent) {
        self.mangas = mangas
        self.mangaContent = mangaRender
        self.horizontal = horizontal
    }
    
    public var body: some View {
        Group {
            if horizontal {
                LazyHGrid(rows: columns) {
                    mangasList
                }
            } else {
                LazyVGrid(columns: columns) {
                    mangasList
                }
            }
        }
    }
    
    @ViewBuilder
    var mangasList: some View {
        ForEach(mangas) { data in
            mangaContent(data)
        }
    }
}
