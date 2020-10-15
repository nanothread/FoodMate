//
//  MealSlot.swift
//  FoodMate
//
//  Created by Andrew Glen on 03/10/2020.
//

import Foundation

/// A space in the day where a meal can be eaten.
public enum MealSlot: String, CaseIterable {
    case lunch
    case dinner
    
    /// The user-facing title of this slot.
    var title: String {
        switch self {
        case .lunch: return NSLocalizedString("Lunch", comment: "Meal eaten at noon.")
        case .dinner: return NSLocalizedString("Dinner", comment: "Meal eaten in the evening.")
        }
    }
    
    /// A pluralised version of `title`.
    var pluralTitle: String {
        switch self {
        case .lunch: return NSLocalizedString("Lunches", comment: "Meals eaten at noon.")
        case .dinner: return NSLocalizedString("Dinners", comment: "Meals eaten in the evening.")
        }
    }
}

extension MealSlot: Identifiable {
    public var id: String { rawValue }
}

extension MealSlot: Comparable {
    /// Orders slots chronologically (i.e. lunch before dinner).
    public static func < (lhs: MealSlot, rhs: MealSlot) -> Bool {
        return lhs == .lunch && rhs == .dinner
    }
}
