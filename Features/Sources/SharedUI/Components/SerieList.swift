//
//  File.swift
//  
//
//  Created by Stephan Deumier on 04/06/2022.
//

import Foundation
import SwiftUI

public struct SerieList<SerieContent: View, T: Identifiable, Y: RandomAccessCollection<T>>: View {
    var series: Y
    var serieContent: (T) -> SerieContent
    var horizontal: Bool
    
    var columns: [GridItem] {
        let size: Double = UIScreen.isLargeScreen ? 130*1.3 : 130
        return [GridItem(.adaptive(size))]
    }
    
    public init(series: Y, horizontal: Bool = false, @ViewBuilder serieRender: @escaping (T) -> SerieContent) {
        self.series = series
        self.serieContent = serieRender
        self.horizontal = horizontal
    }
    
    public var body: some View {
        Group {
            if horizontal {
                LazyHGrid(rows: columns) {
                    seriesList
                }
            } else {
                LazyVGrid(columns: columns) {
                    seriesList
                }
            }
        }
    }
    
    @ViewBuilder
    var seriesList: some View {
        ForEach(series) { data in
            serieContent(data)
        }
    }
}
