//
//  MealRow.swift
//  FoodMate
//
//  Created by Andrew Glen on 03/10/2020.
//

import SwiftUI

struct MealRow: View {
    var meal: Meal
    
    var body: some View {
        HStack {
            if meal.ingredients.flatMap(\.children).contains(where: { $0.location == .freezer }) {
                Image(systemName: "snow")
            }
            Text(meal.name)
        }
    }
}
