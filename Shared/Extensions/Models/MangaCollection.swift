//
//  MangaCollection.swift
//  Dokusho (iOS)
//
//  Created by Stephan Deumier on 26/06/2021.
//

import Foundation

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
}
