//
//  ActiveSourceSectionView.swift
//  ActiveSourceSectionView
//
//  Created by Stephan Deumier on 13/08/2021.
//

import SwiftUI

struct ActiveSourceSectionView: View {
    @FetchRequest(
        sortDescriptors: [SourceEntity.positionOrder],
        predicate: SourceEntity.onlyActiveAndNotFavorite,
        animation: .default
    )
    var sources: FetchedResults<SourceEntity>
    
    var swipe: Bool
    
    var body: some View {
        ForEach(sources) { src in
            if swipe {
                SourceRowWithSwipeView(source: src)
            } else {
                NavigationLink(
                    destination: ExploreSourceView(
                        mangas: .init(sortDescriptors: [], predicate: MangaEntity.sourcePredicate(source: src), animation: .default),
                        vm: .init(for: src)
                    )
                ) {
                    SourceRowView(source: src)
                }
            }
        }
    }
}
