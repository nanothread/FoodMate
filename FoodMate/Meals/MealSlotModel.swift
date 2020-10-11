//
//  MealSlotModel.swift
//  FoodMate
//
//  Created by Andrew Glen on 11/10/2020.
//

import Foundation

// Can't just be optional because we need each model instance to be identifiable
enum MealSlotModel: Hashable, Equatable {
    case filled(Meal)
    case empty(MealSpace)
}
