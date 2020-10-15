//
//  MealPlanView.swift
//  FoodMate
//
//  Created by Andrew Glen on 10/10/2020.
//

import Foundation
import SwiftUI

/// The root of the Meal Plan view tree.
struct MealPlanView: View {
    @State private var creatingMealSpace: MealSpace?
    @Environment(\.managedObjectContext) private var context
    
    var body: some View {
        MealPlanController(creatingMealSpace: $creatingMealSpace)
            .edgesIgnoringSafeArea(.all)
            .sheet(item: $creatingMealSpace) { mealSpace in
                NewMealView(space: mealSpace)
            }
    }
}
