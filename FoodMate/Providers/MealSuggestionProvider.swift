//
//  MealSuggestionProvider.swift
//  FoodMate
//
//  Created by Andrew Glen on 17/10/2020.
//

import Foundation
import CoreData

class MealSuggestionProvider: ObservableObject {
    var context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func suggestMeals(allowRequiresShopping: Bool) -> [Meal] {
        // Suggest meals by least recently made
        // Disallow meals that are already in the plan
        
//        let earliestDayOffset
        []
    }
}
