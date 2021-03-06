//
//  MealSuggestionProvider.swift
//  FoodMate
//
//  Created by Andrew Glen on 17/10/2020.
//

import Foundation
import CoreData
import Combine

/// Generates meal suggestions and manages various suggestion-related settings.
class MealSuggestionProvider: ObservableObject {
    /// If `true`, `currentSuggestions` will only contain meals that can be made with
    /// the ingredients that are already on-hand.
    @Published var avoidShopping = false {
        didSet {
            updateMealSuggestions()
        }
    }
    
    /// The latest suggestions that have been generated.
    @Published var currentSuggestions = [Meal]()
    
    var context: NSManagedObjectContext
    private var allMeals = [Meal]()
    private var cancellables = Set<AnyCancellable>()
    
    init(context: NSManagedObjectContext) {
        self.context = context
        
        do {
            let request: NSFetchRequest<Meal> = Meal.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(key: "scheduledDay", ascending: true)]
            allMeals = try context.fetch(request)
        } catch {
            Logger.coreData.error("MealSuggestionProvider failed to fetch meals: \(error.localizedDescription)")
        }
        
        updateMealSuggestions()
    }
    
    private func updateMealSuggestions() {
        // Suggest meals by least recently made
        // Disallow meals that are already scheduled for the future
        
        let earliestPlannerTime = Date().startOfDay
        let ineligibleMealNames = Set(allMeals.filter { $0.scheduledDay > earliestPlannerTime }.map(\.name))
        var eligibleMeals = allMeals.filter { !ineligibleMealNames.contains($0.name) }
        
        if avoidShopping { // Filter out meals we don't have ingredients for
            eligibleMeals = eligibleMeals.filter { !$0.ingredients.contains(where: { $0.children.isEmpty }) }
        }
        
        currentSuggestions = eligibleMeals.removingDuplicates(of: \.name)
    }
}
