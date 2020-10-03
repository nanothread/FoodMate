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
