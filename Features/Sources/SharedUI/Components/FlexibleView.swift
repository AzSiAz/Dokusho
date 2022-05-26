//
//  FlexibleView.swift
//  Dokusho (iOS)
//
//  Created by Stephan Deumier on 14/06/2021.
//

import SwiftUI
import Common

public struct FlexibleView<Data: Collection, Content: View>: View where Data.Element: Hashable {
    let data: Data
    let availableWidth: CGFloat
    let spacing: CGFloat
    let alignment: HorizontalAlignment
    let content: (Data.Element) -> Content

    @State var elementsSize: [Data.Element: CGSize] = [:]
    
    public init(data: Data, availableWidth: CGFloat, spacing: CGFloat, alignment: HorizontalAlignment, @ViewBuilder content: @escaping (Data.Element) -> Content) {
        self.data = data
        self.availableWidth = availableWidth
        self.spacing = spacing
        self.alignment = alignment
        self.content = content
    }
    
    public var body : some View {
        VStack(alignment: alignment, spacing: spacing) {
            ForEach(computeRows(), id: \.self) { rowElements in
                HStack(spacing: spacing) {
                    ForEach(rowElements, id: \.self) { element in
                        content(element)
                            .fixedSize()
                            .readSize { elementsSize[element] = $0 }
                    }
                }
            }
        }
    }
    
    func computeRows() -> [[Data.Element]] {
        var rows: [[Data.Element]] = [[]]
        var currentRow = 0
        var remainingWidth = availableWidth
        
        for element in data {
            let elementSize = elementsSize[element, default: CGSize(width: availableWidth, height: 1)]
            
            if remainingWidth - (elementSize.width + spacing) >= 0 {
                rows[currentRow].append(element)
            } else {
                currentRow = currentRow + 1
                rows.append([element])
                remainingWidth = availableWidth
            }
            
            remainingWidth = remainingWidth - (elementSize.width + spacing)
        }
        
        return rows
    }
}
