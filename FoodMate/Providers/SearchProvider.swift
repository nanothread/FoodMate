//
//  SearchProvider.swift
//  FoodMate
//
//  Created by Andrew Glen on 03/10/2020.
//

import Foundation
import CoreData

// TODO: Stop blocking the main thread with these requests.
// TODO: Optimise searching. Cache search requests and/or don't
// do a search for "abc" if "ab" returns empty

/// This class provides an interface to search for objects in the persistent store.
class SearchProvider: ObservableObject {
    private var context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    /// Returns the first 3 ingredients whose name matches `searchTerm` (case-insensitive). `searchTerm` is processed before the query to achieve consistent results.
    func getAbstractIngredients(matching searchTerm: String) -> [AbstractIngredient] {
        let trimmedTerm = searchTerm.trimmingCharacters(in: .whitespaces)
        guard !trimmedTerm.isEmpty else { return [] }
        
        let request: NSFetchRequest<AbstractIngredient> = AbstractIngredient.fetchRequest()
        request.fetchLimit = 3
        request.predicate = NSPredicate(format: "name CONTAINS[cd] %@", argumentArray: [trimmedTerm])
        
        do {
            return try context.fetch(request)
        } catch {
            Logger.coreData.error("SearchProvider failed to fetch abstract ingredients for term \(searchTerm): \(error.localizedDescription)")
        }
        
        return []
    }
    
    /// Returns the first 3 distinct meals whose name matches `searchTerm` (case-insensitive). `searchTerm` is processed before the query to achieve consistent results.
    func getMealsWithDistinctNames(matching searchTerm: String) -> [Meal] {
        let trimmedTerm = searchTerm.trimmingCharacters(in: .whitespaces)
        guard !trimmedTerm.isEmpty else { return [] }
            
        
        // TODO: Instead of fetching all meals and sorting, fetch just the names
        // distinctly and then fetch the proper object on save.
        
        let request: NSFetchRequest<Meal> = Meal.fetchRequest()
        request.predicate = NSPredicate(format: "name CONTAINS[cd] %@", argumentArray: [trimmedTerm])
        request.sortDescriptors = [NSSortDescriptor(key: "scheduledDay", ascending: false)]
        
        let limit = 3
        
        do {
            let validMeals = try context.fetch(request)
            
            return Array(
                validMeals
                    .removingDuplicates(of: \.name)
                    .prefix(limit)
            )
            
        } catch {
            Logger.coreData.error("SearchProvider failed to fetch meals for term \(searchTerm): \(error.localizedDescription)")
        }
        
        return []
    }
    
    /// Queries the persistent store to find an ingredient with the given name. If one is not found, a new ingredient is created and returned. The caller should save the managed object context after calling this function. `name` is processed to achieve conistent results.
    func findOrMakeAbstractIngredient(named name: String) -> AbstractIngredient {
        let formattedName = name.trimmingCharacters(in: .whitespaces).firstUppercased
        
        let request: NSFetchRequest<AbstractIngredient> = AbstractIngredient.fetchRequest()
        request.fetchLimit = 1
        request.predicate = NSPredicate(format: "name ==[c] %@", argumentArray: [formattedName])
        
        var results = [AbstractIngredient]()
        do {
            results = try context.fetch(request)
        } catch {
            Logger.coreData.error("SearchProvider failed to fetch abstract ingredients matching \(formattedName): \(error.localizedDescription)")
        }
        
        if let ingredient = results.first {
            return ingredient
        }
        
        let ingredient = AbstractIngredient(context: context)
        ingredient.name = formattedName
        return ingredient
    }
    
    
}
