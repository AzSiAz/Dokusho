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

    @Published var searchText: String = ""
    @Published var showSettings = false
    @Published var showChangeFilter = false
    @Published var selectedCollection = 0
    @Published var refreshStatus: [CollectionEntity: RefreshStatus] = [:]
    
    func changeFilter(collection: CollectionEntity, newFilterState: CollectionEntityFilter) {
//        dataManager.updateCollection(collection: collection, newFilterState: newFilterState)
    }
    
    func refreshLib(for collection: CollectionEntity) {
//        refreshStatus[collection] = RefreshStatus(isRefreshing: true, refreshProgress: 0, refreshCount: 0, refreshTitle: "")
//
//        Task.detached(priority: .userInitiated) {
//            await DataManager.shared.refreshCollection(for: collection, onProgress: { (progress, count, title) in
//                self.updateRefreshStatus(collection: collection, newStatus: RefreshStatus(isRefreshing: true, refreshProgress: progress, refreshCount: count, refreshTitle: title))
//            })
//
//            self.updateRefreshStatus(collection: collection, newStatus: nil)
//        }
    }
    
    func updateRefreshStatus(collection: CollectionEntity, newStatus: RefreshStatus? = nil) {
//        DispatchQueue.main.async {
//            self.refreshStatus[collection] = newStatus
//        }
    }
}
