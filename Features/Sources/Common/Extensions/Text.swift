//
//  File.swift
//  
//
//  Created by Stephan Deumier on 23/03/2024.
//

import Foundation
import SwiftUI

public protocol Labelized {
    func label() -> LocalizedStringKey
}

public extension Text {
    init<S>(_ val: S) where S: Labelized {
        self.init(val.label())
    }
}
