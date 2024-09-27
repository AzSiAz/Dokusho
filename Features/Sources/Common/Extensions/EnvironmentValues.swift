//
//  EnvironmentValues.swift
//  Dokusho
//
//  Created by Stef on 20/10/2021.
//

import Foundation
import SwiftUI

public extension UIApplication {
    var keyWindow: UIWindow? {
        connectedScenes
            .compactMap {
                $0 as? UIWindowScene
            }
            .flatMap {
                $0.windows
            }
            .first {
                $0.isKeyWindow
            }
    }
}
