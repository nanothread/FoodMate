//
//  Date+Extensions.swift
//  FoodMate
//
//  Created by Andrew Glen on 03/10/2020.
//

import Foundation

extension Date {
    func adding(days: Int) -> Date {
        Calendar.current.date(byAdding: DateComponents(day: days), to: self)!
    }
    
    var daysFromToday: Int {
        Calendar.current.dateComponents([.day], from: Date(), to: self).day!
    }
    
    func isInSameDay(as other: Date) -> Bool {
        Calendar.current.compare(self, to: other, toGranularity: .day) == .orderedSame
    }
    
    static func offsetByDays(_ days: Int) -> Date {
        Date().adding(days: days)
    }
}
