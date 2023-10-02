//
//  String.swift
//  Dokusho
//
//  Created by Stephan Deumier on 02/07/2021.
//

import Foundation

extension String: Error {}

extension String {
    var floatValue: Float? {
        NumberFormatter().number(from: self)?.floatValue
    }
    
    var doubleValue: Double? {
        NumberFormatter().number(from: self)?.doubleValue
    }
}

extension String: Identifiable {
    public var id: String { self }
}
