//
//  MealSpace.swift
//  FoodMate
//
//  Created by Andrew Glen on 03/10/2020.
//

import Foundation

struct MealSpace: Identifiable {
    var id = UUID()
    
    var day: Date
    var slot: MealSlot
}

extension MealSpace: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(day)
        hasher.combine(slot)
    }
}

extension MealSpace: Comparable {
    static func < (lhs: MealSpace, rhs: MealSpace) -> Bool {
        Calendar.current.compare(lhs.day, to: rhs.day, toGranularity: .day) == .orderedAscending &&
            lhs.slot < rhs.slot
    }
}
