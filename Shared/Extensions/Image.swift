//
//  Image.swift
//  Dokusho
//
//  Created by Stef on 07/05/2022.
//

import SwiftUI

extension Image {
    func addPinchAndPan() -> some View {
        self.modifier(PinchAndPanImage())
    }
}
