//
//  File.swift
//  
//
//  Created by Stephan Deumier on 07/10/2023.
//

import Foundation
import MangaScraper

public extension Manga {
    enum Status: String, Codable {
        case complete = "Complete", ongoing = "Ongoing", unknown = "Unknown"
        
        public init(rawValue: SourceMangaCompletion) {
            switch(rawValue) {
            case .complete: self = .complete
            case .ongoing: self = .ongoing
            case .unknown: self = .unknown
            }
        }
    }
    
    enum Kind: String, Codable {
        case manga = "Manga", manhua = "Manhua", manhwa = "Manhwa", doujinshi = "Doujinshi", unknown = "Unknown"
        
        public init(rawValue: SourceMangaType) {
            switch(rawValue) {
            case .doujinshi: self = .doujinshi
            case .manga: self = .manga
            case .manhua: self = .manhua
            case .manhwa: self = .manhwa
            case .unknown: self = .unknown
            }
        }
    }
}
