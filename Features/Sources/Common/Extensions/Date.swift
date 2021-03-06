//
//  Date.swift
//  Hanako
//
//  Created by Stephan Deumier on 07/01/2021.
//

import Foundation

public extension Date {
    static func from(year: Int, month: Int, day: Int, calendarType: Calendar.Identifier = .gregorian) -> Date {
        var dateComponents = DateComponents()
        dateComponents.year = year
        dateComponents.month = month
        dateComponents.day = day
        
        return Calendar(identifier: calendarType).date(from: dateComponents)!
    }
}
