//
//  LibraryRootView.swift
//  Dokusho
//
//  iPad-first Library: a collections sidebar + a detail column that hosts the
//  selected collection's grid and pushes manga detail. Collapses to a stack on
//  iPhone via NavigationSplitView's adaptive behavior.
//

import SwiftUI
import DataKit
import MangaScraper
import MangaDetail

public struct LibraryRootView: View {
    @State private var selectedCollectionId: MangaCollection.ID?

    public init() {}

    public var body: some View {
        NavigationSplitView {
            CollectionSidebar(selectedCollectionId: $selectedCollectionId)
        } detail: {
            NavigationStack {
                Group {
                    if let id = selectedCollectionId {
                        CollectionGridPane(collectionId: id)
                            .id(id)
                    } else {
                        ContentUnavailableView("Select a Collection", systemImage: "books.vertical")
                    }
                }
                .navigationDestination(for: DetailedMangaInList.self) { data in
                    MangaDetail(mangaId: data.manga.mangaId, scraper: data.scraper)
                }
            }
        }
    }
}
