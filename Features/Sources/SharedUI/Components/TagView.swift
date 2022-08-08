//
//  File.swift
//  
//
//  Created by Stef on 05/08/2022.
//

import SwiftUI

public struct TagView: Layout {
    var alignment: Alignment
    var spacing: CGFloat
    
    public init(alignment: Alignment = .center, spacing: CGFloat = 5) {
        self.alignment = alignment
        self.spacing = spacing
    }
    
    public func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
//        let maxHeight = subviews.reduce(.zero) { current, view in max(current, view.dimensions(in: .unspecified).height) }
//        print(proposal.replacingUnspecifiedDimensions())
//        return .init(width: proposal.width ?? 0, height: (maxHeight * CGFloat(subviews.count) / CGFloat(5)) + spacing)
//        let maxSize = maxSize(subviews: subviews)
//        let spacings = spacings(subviews: subviews)
//        let totalSpacing = spacings.reduce(0.0, +)
//
//        return CGSize(
//            width: maxSize.width * CGFloat(subviews.count) + totalSpacing,
//            height: maxSize.height
//        )

        print(proposal.width)
        return proposal.replacingUnspecifiedDimensions()
    }
    
    public func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let rows = getRows(in: bounds, proposal: proposal, subviews: subviews)
        
        var origin = bounds.origin
        
        for row in rows {
            origin.x = (alignment == .leading ? bounds.minX : (alignment == .trailing ? row.1 : row.1 / 2))
            
            for view in row.0 {
                let viewSize = view.sizeThatFits (proposal)
                view.place(at: origin, proposal: proposal)
                origin.x += (viewSize.width + spacing)
            }

            let maxHeight = row.0.compactMap { view -> CGFloat? in
                return view.sizeThatFits(proposal).height
            }.max () ?? 0
            origin.y += (maxHeight + spacing)
        }
    }
    
    private func getRows(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews) -> [([LayoutSubviews.Element], Double)] {
        var origin = bounds.origin
        let maxWidth = bounds.width

        var row: ([LayoutSubviews.Element], Double) = ([], 0.0)
        var rows: [([LayoutSubviews.Element], Double)] = []
        
        for view in subviews {
            let viewSize = view.sizeThatFits(proposal)

            if (origin.x + viewSize.width + spacing) > maxWidth {
                row.1 = (bounds.maxX - origin.x + bounds.minX + spacing)
                rows.append(row)
                row.0.removeAll()
                origin.x = bounds.origin.x
            }

            row.0.append(view)

            origin.x += (viewSize.width + spacing)
        }
        
        if !row.0.isEmpty {
            row.1 = (bounds.maxX - origin.x + bounds.minX + spacing)
            rows.append(row)
        }
        
        return rows
    }
}
