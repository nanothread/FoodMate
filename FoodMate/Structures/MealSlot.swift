//
//  MealSlot.swift
//  FoodMate
//
//  Created by Andrew Glen on 03/10/2020.
//

import Foundation

public enum MealSlot: String, CaseIterable {
    case lunch
    case dinner
    
    var title: String { rawValue.firstUppercased }
}

extension MealSlot: Identifiable {
    public var id: String { rawValue }
}
