//
//  MealSlotModel.swift
//  FoodMate
//
//  Created by Andrew Glen on 11/10/2020.
//

import Foundation

/// Contains data for each row of the meal planner, including empty rows.
///
/// This can't just be an `Optional<Meal>` because we need empty rows to be identifiable.
enum MealSlotModel: Hashable, Equatable {
    case filled(Meal)
    case empty(MealSpace)
}
