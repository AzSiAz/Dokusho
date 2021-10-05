//
//  IntentHandler.swift
//  DokushoIntentHandler
//
//  Created by Stef on 05/10/2021.
//

import Intents
import CoreData
import WidgetKit

class IntentHandler: INExtension {
    
    override func handler(for intent: INIntent) -> Any {
        // This is the default implementation.  If you want different objects to handle different intents,
        // you can override this and return the handler you want for that particular intent.
        
        return self
    }
    
}

extension IntentHandler: ChooseCollectionIntentHandling {
    func provideCollectionOptionsCollection(for intent: ChooseCollectionIntent, with completion: @escaping (INObjectCollection<CollectionIntentType>?, Error?) -> Void) {
        do {
            let req = CollectionEntity.fetchRequest()
            let data = try PersistenceController.shared.container.viewContext.fetch(req)
            completion(INObjectCollection(items: data.map { CollectionIntentType(identifier: $0.uuid?.uuidString, display: $0.getName()) }), nil)
        } catch {
            completion(nil, error)
        }
    }
    
    func defaultCollection(for intent: ChooseCollectionIntent) -> CollectionIntentType? {
        do {
            let req = CollectionEntity.collectionFetchRequest
            guard let collection = try PersistenceController.shared.container.viewContext.fetch(req).first else { return nil }
            
            return CollectionIntentType(identifier: collection.uuid?.uuidString, display: collection.getName())
        } catch {
            return nil
        }
    }
}
