//
//  File.swift
//  
//
//  Created by Stef on 11/05/2022.
//

import Foundation
import SwiftUI

private struct AppDatabaseKey: EnvironmentKey {
    static var defaultValue: AppDatabase { .makeEmpty() }
}

public extension EnvironmentValues {
    var appDatabase: AppDatabase {
        get { self[AppDatabaseKey.self] }
        set { self[AppDatabaseKey.self] = newValue }
    }
}
