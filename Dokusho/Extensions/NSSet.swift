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

extension Optional where Wrapped: Sequence {
    func sorted<T: Comparable>(by keyPath: KeyPath<Wrapped.Element, T>) -> [Wrapped.Element] {
        if let self = self {
            return self.sorted { a, b in
                return a[keyPath: keyPath] < b[keyPath: keyPath]
            }
        }
        
        return [Wrapped.Element]()
    }
}

