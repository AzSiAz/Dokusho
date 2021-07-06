//
//  Persistence.swift
//  Shared
//
//  Created by Stephan Deumier on 30/05/2021.
//

import CoreData
import OSLog
import Combine

class PersistenceController {
    static var shared = PersistenceController(inMemory: false)
    static var inMemory = PersistenceController(inMemory: true)

    let container: NSPersistentCloudKitContainer
    var subscriptions: Set<AnyCancellable> = []
    
    private lazy var historyQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        return queue
    }()

    init(inMemory: Bool = false) {
        container = NSPersistentCloudKitContainer(name: "Dokusho")
        
        Logger.persistence.info("Starting CoreData \(inMemory ? "in memory" : "in sync") mode")
        
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        
        container.persistentStoreDescriptions.first!.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
        
        container.loadPersistentStores { (storeDescription, error) in
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
                fatalError()
            }
            
            self.container.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
            self.container.viewContext.automaticallyMergesChangesFromParent = true
        }
        
//        NotificationCenter.default
//            .publisher(for: .NSPersistentStoreRemoteChange)
//            .sink { notification in print(notification) }
//            .store(in: &self.subscriptions)
    }
}
