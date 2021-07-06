//
//  LibraryVM.swift
//  Dokusho (iOS)
//
//  Created by Stephan Deumier on 22/06/2021.
//

import Foundation
import SwiftUI
import CoreData

class LibraryVM: ObservableObject {
    struct RefreshStatus {
        var isRefreshing: Bool
        var refreshProgress: Int
        var refreshCount: Int
        var refreshTitle: String
    }
    
//    private let mangaCollectionController: NSFetchedResultsController<MangaCollection>
    private let dataManager = DataManager.shared

    @Published var searchText: String = ""
    @Published var showSettings = false
    @Published var showChangeFilter = false
    @Published var selectedTab = 0

    @Published var refreshStatus: [MangaCollection: RefreshStatus] = [:]
    
    func changeFilter(collection: MangaCollection, newFilterState: MangaCollection.Filter) {
        dataManager.updateCollection(collection: collection, newFilterState: newFilterState)
    }
    
    func refreshLib(for collection: MangaCollection) {
        refreshStatus[collection] = RefreshStatus(isRefreshing: true, refreshProgress: 0, refreshCount: 0, refreshTitle: "")

        async {
            await dataManager.refreshCollection(for: collection, onProgress: { (progress, count, title) in
                DispatchQueue.main.async {
                    self.refreshStatus[collection] = RefreshStatus(isRefreshing: true, refreshProgress: progress, refreshCount: count, refreshTitle: title)
                }
            })
            
            DispatchQueue.main.async {
                self.refreshStatus[collection] = nil
            }
        }
    }
}
