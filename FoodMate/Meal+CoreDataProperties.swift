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

    /// The name the user has given this meal.
    @NSManaged public var name: String
    /// The day this meal has been scheduled for in the planner (components finer than
    /// `.day` are not used).
    @NSManaged public var scheduledDay: Date
    /// The ingredients required to make this meal.
    @NSManaged public var ingredients: Set<AbstractIngredient>

    /// The slot this meal has been scheduled for in the planner.
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

extension Meal {
    convenience init(context: NSManagedObjectContext, name: String, space: MealSpace, ingredients: Set<AbstractIngredient>) {
        self.init(context: context)
        self.name = name
        self.scheduledDay = space.day
        self.scheduledSlot = space.slot
        self.ingredients = ingredients
    }
}
