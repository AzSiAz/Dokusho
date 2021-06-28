//
//  MangaCollection+CD.swift
//  Dokusho (iOS)
//
//  Created by Stephan Deumier on 28/06/2021.
//

import Foundation
import CoreData

@objc(MangaCollection)
class MangaCollection: NSManagedObject {
    @NSManaged var id: UUID?
    @NSManaged var name: String?
    @NSManaged var filterRaw: String?
    
    @NSManaged var mangas: Set<Manga>?
    
    static func fetchRequest() -> NSFetchRequest<MangaCollection> {
        return NSFetchRequest<MangaCollection>(entityName: "MangaCollection")
    }
}

extension MangaCollection {
    enum Filter: String, CaseIterable {
        case all
        case read
        case unread
        
        func isNotAll() -> Bool {
            return !(self == .all)
        }
    }
    
    var filter: Filter {
        get {
            return .init(rawValue: self.filterRaw ?? "") ?? .all
        }
        
        set {
            self.filterRaw = newValue.rawValue
        }
    }
    
    func addToCollection(_ manga: Manga) {
        self.mangas?.insert(manga)
        manga.collection = self
    }
    
    func removeFromCollection(_ manga: Manga) {
        self.mangas?.remove(manga)
        manga.collection = nil
    }
}
