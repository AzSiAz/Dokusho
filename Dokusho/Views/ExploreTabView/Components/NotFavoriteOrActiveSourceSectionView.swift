//
//  NotFavoriteOrActiveSourceSectionView.swift
//  NotFavoriteOrActiveSourceSectionView
//
//  Created by Stephan Deumier on 13/08/2021.
//

import SwiftUI

struct NotFavoriteOrActiveSourceSectionView: View {
    @FetchRequest(
        sortDescriptors: [SourceEntity.positionOrder],
        predicate: SourceEntity.NotFavoriteOrActive,
        animation: .default
    )
    var sources: FetchedResults<SourceEntity>
    
    var swipe: Bool
    
    var body: some View {
        ForEach(sources) { src in
            if swipe {
                SourceRowWithSwipeView(source: src)
            } else {
                SourceRowView(source: src)
            }
        }
    }
}
