//
//  NSSet.swift
//  NSSet
//
//  Created by Stephan Deumier on 18/08/2021.
//

import Foundation
import CoreData

extension Optional where Wrapped == NSSet {
    func asSet<T: Hashable>(of: T.Type) -> Set<T> {
        return self as! Set<T>
    }
}

extension Optional where Wrapped == NSSet {
    func array<T: Hashable>(of: T.Type) -> [T] {
        if let set = self as? Set<T> {
            return Array(set)
        }
        return [T]()
    }
}
