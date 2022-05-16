//
//  File.swift
//  
//
//  Created by Stef on 11/05/2022.
//

import Foundation

public struct Page: Hashable {
    let index: Int
    let imageURL: String?
    let base64: String?
    let text: String?
}

enum MangaViewer: Int {
    case defaultViewer = 0
    case rtl = 1
    case ltr = 2
    case vertical = 3
    case scroll = 4
}
