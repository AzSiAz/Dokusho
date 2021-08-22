//
//  Persistence.swift
//  Dokusho
//
//  Created by Stephan Deumier on 17/08/2021.
//

import CoreData
import OSLog

class PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentContainer

    init() {
        container = NSPersistentContainer(name: "Dokusho")
        
        container.persistentStoreDescriptions.first!.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
        
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                Logger.persistence.error("Unresolved error \(error) with \(error.userInfo)")
                fatalError()
            }
            
            self.container.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
            self.container.viewContext.automaticallyMergesChangesFromParent = true
        }
    }
    
    func backgroundCtx() -> NSManagedObjectContext {
        let ctx = container.newBackgroundContext()
        
        ctx.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        ctx.automaticallyMergesChangesFromParent = true
        
        return ctx
    }
}
