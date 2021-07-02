//
//  LibraryVM.swift
//  Dokusho (iOS)
//
//  Created by Stephan Deumier on 22/06/2021.
//

import Foundation
import SwiftUI
import CoreData

class LibraryVM: NSObject, ObservableObject {
    struct RefreshStatus {
        var isRefreshing: Bool
        var refreshProgress: Int
        var refreshCount: Int
        var refreshTitle: String
    }
    
    private let mangaCollectionController: NSFetchedResultsController<MangaCollection>
    private let dataManager = DataManager.shared

    @Published var collections: [MangaCollection] = []
    @Published var searchText: String = ""
    @Published var showSettings = false
    @Published var showChangeFilter = false
    @Published var selectedTab = 0

    @Published var refreshStatus: [MangaCollection: RefreshStatus] = [:]

    override init() {
        mangaCollectionController = NSFetchedResultsController(
            fetchRequest: MangaCollection.collectionFetchRequest,
            managedObjectContext: PersistenceController.shared.container.viewContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        super.init()

        mangaCollectionController.delegate = self
        
        refreshCollections()
    }
    
    func refreshCollections() {
        do {
            try mangaCollectionController.performFetch()
            self.collections = mangaCollectionController.fetchedObjects ?? []
        } catch {
            print(error)
        }
    }
    
    func getMangas(collection: MangaCollection) -> [Manga] {
        guard collection.mangas?.count != 0 else { return [] }
        guard let mangas = collection.mangas else { return [] }
        
        let sort = SortDescriptor(\Manga.lastChapterUpdate, order: .reverse)
        
        switch collection.filter {
            case .all:
                return mangas.sorted(using: sort)
            case .read:
                return mangas
                    .filter { manga in
                        guard let chapters = manga.chapters else { return false }

                        return chapters.allSatisfy { !$0.status.isUnread() }
                    }
                    .sorted(using: sort)
            case .unread:
                return mangas
                    .filter { manga in
                        guard let chapters = manga.chapters else { return false }
                        return chapters.contains { $0.status.isUnread() }
                    }
                    .sorted(using: sort)
        }
    }
    
    func markChaptersMangaAs(for manga: Manga, status: MangaChapter.Status) {
        dataManager.markChaptersAllAs(for: manga, status: status)
        refreshCollections()
    }
    
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

extension LibraryVM: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        guard let collections = controller.fetchedObjects as? [MangaCollection] else { return }
        
        self.collections = collections
    }
}
