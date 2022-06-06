//
//  URL.swift
//  URL
//
//  Created by Stephan Deumier on 25/08/2021.
//

import Foundation

public extension URL {
    static func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}
