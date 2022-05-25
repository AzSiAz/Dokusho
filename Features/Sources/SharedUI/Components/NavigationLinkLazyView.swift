//
//  NavigationLinkLazyView.swift
//  Hanako
//
//  Created by Stephan Deumier on 10/01/2021.
//

import SwiftUI

public struct NavigationLinkLazyView<Content: View>: View {
    let build: () -> Content
    
    public init(_ build: @autoclosure @escaping () -> Content) {
        self.build = build
    }
    
    public var body: Content {
        build()
    }
}
