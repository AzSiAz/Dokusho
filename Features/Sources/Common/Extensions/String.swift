//
//  String.swift
//  Dokusho
//
//  Created by Stef on 23/12/2021.
//

import Foundation

extension String: @retroactive Identifiable {
    public var id: String { self }
}
