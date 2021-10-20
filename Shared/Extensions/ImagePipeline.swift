//
//  ImagePipeline.swift
//  Dokusho
//
//  Created by Stef on 20/10/2021.
//

import Foundation
import Nuke

extension ImagePipeline {
    static var inMemory: ImagePipeline {
        return  ImagePipeline { $0.imageCache =  ImageCache() }
    }
}
