//
//  Persistence.swift
//  Shared
//
//  Created by Stephan Deumier on 30/05/2021.
//

import CoreData
import OSLog

struct PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentCloudKitContainer

    init(inMemory: Bool = false) {
        container = NSPersistentCloudKitContainer(name: "Dokusho")
        
        Logger.persistence.info("Starting CoreData \(inMemory ? "in memory" : "in sync") mode")
        
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

                /*
                Typical reasons for an error here include:
                * The parent directory does not exist, cannot be created, or disallows writing.
                * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                * The device is out of space.
                * The store could not be migrated to the current model version.
                Check the error message to determine what the actual problem was.
                */
                
                Logger.persistence.error("Unresolved error \(error) with \(error.userInfo)")

                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
    }
}
