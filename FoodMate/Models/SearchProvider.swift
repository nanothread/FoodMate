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

class SearchProvider: ObservableObject {
    private var context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
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
    
    func getMealsWithDistinctNames(matching searchTerm: String) -> [Meal] {
        let trimmedTerm = searchTerm.trimmingCharacters(in: .whitespaces)
        guard !trimmedTerm.isEmpty else { return [] }
        
        let request: NSFetchRequest<Meal> = Meal.fetchRequest()
        request.fetchLimit = 3
        request.predicate = NSPredicate(format: "name CONTAINS[cd] %@", argumentArray: [trimmedTerm])
        request.propertiesToFetch = ["name"]
        request.returnsDistinctResults = true
        request.sortDescriptors = [NSSortDescriptor(key: "scheduledDay", ascending: false)]
        
        do {
            return try context.fetch(request)
        } catch {
            Logger.coreData.error("SearchProvider failed to fetch meals for term \(searchTerm): \(error.localizedDescription)")
        }
        
        return []
    }
    
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
