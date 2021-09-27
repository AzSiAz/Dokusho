//
//  FavoriteSourceSectionView.swift
//  FavoriteSourceSectionView
//
//  Created by Stephan Deumier on 13/08/2021.
//

import SwiftUI

struct FavoriteSourceSectionView: View {
    @FetchRequest(
        sortDescriptors: [SourceEntity.positionOrder],
        predicate: SourceEntity.onlyFavoriteAndActive,
        animation: .default
    )
    var sources: FetchedResults<SourceEntity>
    
    var swipe: Bool
    
    var body: some View {
        ForEach(sources) { src in
            if swipe {
                SourceRowWithSwipeView(source: src)
            }
//            else {
//                NavigationLink(
//                    destination: ExploreSourceView(
//                        mangas: .init(sortDescriptors: [], predicate: MangaEntity.inCollectionForSource(source: src), animation: .default),
//                        vm: .init(for: src)
//                    )
//                ) {
//                    SourceRowView(source: src)
//                }
//            }
        }
    }
}
