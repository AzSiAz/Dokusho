//
//  ImagePipeline.swift
//  Dokusho
//
//  Created by Stef on 20/10/2021.
//

import Foundation
import Nuke

public extension ImagePipeline {
    static var inMemory: ImagePipeline {
        return  ImagePipeline { $0.imageCache =  ImageCache() }
    }
    
    static var coverCache: ImagePipeline {
        ImagePipeline {
            let dataLoader: DataLoader = {
                let config = URLSessionConfiguration.default
                config.urlCache = nil
                return DataLoader(configuration: config)
            }()
            
            $0.dataCache = DataCache.DiskCover
            $0.dataLoader = dataLoader
            $0.isRateLimiterEnabled = true
            $0.dataCachePolicy = .automatic
        }
    }
}

public extension DataCache {
    static var DiskCover: DataCache? {
        let dataCache = try? DataCache(name: "tech.azsiaz.Dokusho.cover")
        dataCache?.sizeLimit = 1024 * 1024 * 1500
        
        return dataCache
    }
}
