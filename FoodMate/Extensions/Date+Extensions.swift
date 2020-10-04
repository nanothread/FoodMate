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
}
