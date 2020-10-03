//
//  SearchProvider.swift
//  FoodMate
//
//  Created by Andrew Glen on 03/10/2020.
//

import Foundation
import CoreData

class SearchProvider: ObservableObject {
    private var context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func getAbstractIngredients(matching searchTerm: String) -> [AbstractIngredient] {
        let request: NSFetchRequest<AbstractIngredient> = AbstractIngredient.fetchRequest()
        request.fetchLimit = 5
        request.predicate = NSPredicate(format: "name CONTAINS[c] %@", argumentArray: [searchTerm])
        
        do {
            return try context.fetch(request)
        } catch {
            Logger.coreData.error("SearchProvider failed to fetch abstract ingredients for term \(searchTerm): \(error.localizedDescription)")
        }
        
        return []
    }
}
