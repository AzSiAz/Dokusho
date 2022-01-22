//
//  ManageCollectionsModal.swift
//  Dokusho (iOS)
//
//  Created by Stephan Deumier on 26/06/2021.
//

import SwiftUI
import GRDBQuery

struct CollectionPage: View {
    @Query<OneMangaCollectionRequest> var collection: MangaCollection?
    
    @State var searchTerm = ""
    @State var showFilter = false
    @State var collectionFilter: MangaCollectionFilter
    @State var collectionOrderField: MangaCollectionOrder.Field
    @State var collectionOrderDirection: MangaCollectionOrder.Direction
    
    init(collection : MangaCollection) {
        _collectionFilter = .init(initialValue: collection.filter)
        _collectionOrderField = .init(initialValue: collection.order.field)
        _collectionOrderDirection = .init(initialValue: collection.order.direction)
        _collection = Query(OneMangaCollectionRequest(collectionId: collection.id))
    }
    
    var body: some View {
        if let collection = collection {
            ScrollView {
                FilteredCollectionPage(collection: collection, searchTerm: searchTerm)
            }
            .searchable(text: $searchTerm)
            .toolbar {
                LibraryToolbarView(
                    collection: collection,
                    showFilter: $showFilter,
                    collectionFilter: $collectionFilter,
                    collectionOrderField: $collectionOrderField,
                    collectionOrderDirection: $collectionOrderDirection
                )
            }
        }
    }
}
