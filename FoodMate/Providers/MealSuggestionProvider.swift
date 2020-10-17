//
//  MealSuggestionProvider.swift
//  FoodMate
//
//  Created by Andrew Glen on 17/10/2020.
//

import Foundation
import CoreData
import Combine

class MealSuggestionProvider: ObservableObject {
    @Published var avoidShopping = false {
        didSet {
            updateMealSuggestions()
        }
    }
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
    
    func updateMealSuggestions() {
        // Suggest meals by least recently made
        // Disallow meals that are already scheduled for the future
        
        let earliestPlannerTime = Date().startOfDay
        let ineligibleMealNames = Set(allMeals.filter { $0.scheduledDay > earliestPlannerTime }.map(\.name))
        var eligibleMeals = allMeals.filter { !ineligibleMealNames.contains($0.name) }
        
        if avoidShopping { // Filter out meals we don't have ingredients for
            eligibleMeals = eligibleMeals.filter { !$0.ingredients.contains(where: { $0.children.isEmpty }) }
        }
        
        currentSuggestions = eligibleMeals.removeDuplicates(of: \.name)
    }
}

extension Array {
    func removeDuplicates<Target: Hashable>(of keyPath: KeyPath<Element, Target>) -> Self {
        var visitedItems = Set<Target>()
        var result = [Element]()
        
        for item in self where !visitedItems.contains(item[keyPath: keyPath]) {
            result.append(item)
            visitedItems.insert(item[keyPath: keyPath])
        }
        
        return result
    }
}
