//
//  File.swift
//  
//
//  Created by Stephan Deumier on 31/05/2022.
//

import Foundation
import SwiftUI

public extension ObservableObject {
    func animateAsyncChange(_ animation: Animation? = .default, _ change: @Sendable @escaping () -> Void) async {
        await MainActor.run {
            withAnimation(animation) {
                change()
            }
        }
    }
    
    func asyncChange(_ change: @Sendable @escaping () -> Void) async {
        await MainActor.run {
            change()
        }
    }
}
