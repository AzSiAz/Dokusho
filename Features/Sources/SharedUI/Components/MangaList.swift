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
    
    var columns: [GridItem] = [GridItem(.adaptive(minimum: 130, maximum: 130))]
    
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
