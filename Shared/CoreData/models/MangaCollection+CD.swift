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
    @NSManaged var position: Int16
    
    @NSManaged var mangas: Set<Manga>?
    
    convenience init(context ctx: NSManagedObjectContext, id: UUID = UUID(), name: String, position: Int16) {
        self.init(entity: Self.entity(), insertInto: ctx)
        
        self.id = id
        self.name = name
        self.position = position
        self.filter = .all
    }
}

extension MangaCollection: Identifiable {
    enum Filter: String, CaseIterable {
        case all = "All"
        case read = "Only Read"
        case unread = "Only Reading"
        
        func isNotAll() -> Bool {
            return self != .all
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
        guard self.mangas?.contains(manga) == false else { return }
        
        self.mangas?.insert(manga)
        manga.collection = self
    }
    
    func removeFromCollection(_ manga: Manga) {
        self.mangas?.remove(manga)

        manga.collection = nil
    }
}

extension MangaCollection {
    static func fetchRequest() -> NSFetchRequest<MangaCollection> {
        return NSFetchRequest<MangaCollection>(entityName: "MangaCollection")
    }
    
    static func fetchOne(collectionId: UUID, ctx: NSManagedObjectContext) -> MangaCollection? {
        let req = MangaCollection.fetchRequest()
        req.fetchLimit = 1
        req.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(format: "id = %@", collectionId.uuidString),
        ])
        let res = try? ctx.fetch(req)
        
        return res?.first
    }
    
    static func fetchMany(ctx: NSManagedObjectContext) -> [MangaCollection]? {
        return try? ctx.fetch(MangaCollection.collectionFetchRequest)
    }
    
    static var collectionFetchRequest: NSFetchRequest<MangaCollection> {
        let request = MangaCollection.fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \MangaCollection.position, ascending: true),
        ]

        return request
    }
}
