//
//  Meal+CoreDataProperties.swift
//  FoodMate
//
//  Created by Andrew Glen on 03/10/2020.
//
//

import Foundation
import CoreData


extension Meal {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Meal> {
        return NSFetchRequest<Meal>(entityName: "Meal")
    }

    @NSManaged public var name: String
    @NSManaged public var scheduledDay: Date
    @NSManaged public var ingredients: Set<Ingredient>
    @NSManaged public var parent: AbstractMeal

    public var scheduledSlot: MealSlot {
        get {
            MealSlot(rawValue: properlyGetPrimitiveValue(forKey: "scheduledSlot") as! String)!
        }
        set {
            properlySetPrimitiveValue(newValue.rawValue, forKey: "scheduledSlot")
        }
    }
}

// MARK: Generated accessors for ingredients
extension Meal {

    @objc(addIngredientsObject:)
    @NSManaged public func addToIngredients(_ value: Ingredient)

    @objc(removeIngredientsObject:)
    @NSManaged public func removeFromIngredients(_ value: Ingredient)

    @objc(addIngredients:)
    @NSManaged public func addToIngredients(_ values: NSSet)

    @objc(removeIngredients:)
    @NSManaged public func removeFromIngredients(_ values: NSSet)

}

extension Meal : Identifiable {

}
