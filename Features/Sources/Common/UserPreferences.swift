//
//  File.swift
//  
//
//  Created by Stephan Deumier on 01/10/2023.
//

import Foundation
import SwiftUI

@Observable public class UserPreferences {
    class Storage {
        // Reader Preference
        @AppStorage("USE_NEW_HORIZONTAL_READER") var useNewHorizontalReader = false
        @AppStorage("USE_NEW_VERTICAL_READER") var useNewVerticalReader = false
        @AppStorage("NUMBER_OF_PRELOADED_IMAGES") var numberOfPreloadedImages = 3
        
        // Library preference
        @AppStorage("ONLY_UPDATE_ALL_READ") var onlyUpdateAllRead = true
        
        init() {}
    }
    
    public static let shared = UserPreferences()
    private let storage = Storage()
    
    public var useNewHorizontalReader: Bool {
        didSet {
            storage.useNewHorizontalReader = useNewHorizontalReader
        }
    }
    
    public var useNewVerticalReader: Bool {
        didSet {
            storage.useNewVerticalReader = useNewVerticalReader
        }
    }
    
    public var numberOfPreloadedImages: Int {
        didSet {
            storage.numberOfPreloadedImages = numberOfPreloadedImages
        }
    }
    
    public var onlyUpdateAllRead: Bool {
        didSet {
            storage.onlyUpdateAllRead = onlyUpdateAllRead
        }
    }
    
    private init() {
        useNewHorizontalReader = storage.useNewHorizontalReader
        useNewVerticalReader = storage.useNewVerticalReader
        numberOfPreloadedImages = storage.numberOfPreloadedImages
        onlyUpdateAllRead = storage.onlyUpdateAllRead
    }
}
