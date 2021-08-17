//
//  NavigationLinkLazyView.swift
//  Hanako
//
//  Created by Stephan Deumier on 10/01/2021.
//

import SwiftUI

struct NavigationLinkLazyView<Content: View>: View {
    let build: () -> Content
    init(_ build: @autoclosure @escaping () -> Content) {
        self.build = build
    }
    var body: Content {
        build()
    }
}
