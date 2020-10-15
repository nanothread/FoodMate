//
//  Ingredient+CoreDataProperties.swift
//  FoodMate
//
//  Created by Andrew Glen on 03/10/2020.
//
//

import Foundation
import CoreData


extension Ingredient {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Ingredient> {
        return NSFetchRequest<Ingredient>(entityName: "Ingredient")
    }

    /// The name the user has given this ingredient. Should always be (but is not guaranteed to be)
    /// equal to `parent.name`.
    @NSManaged public var name: String
    /// The date this ingredient is expected to expire, to the nearest day.
    @NSManaged public var expiryDate: Date?
    /// The meals in the planner that use this ingredient.
    @NSManaged public var meals: Set<Meal>
    /// The ingredient that this `Ingredient` is a concrete instance of. For example, the parent may be
    /// 'Eggs' (the idea of eggs), and this `Ingredient` may be one of its two children, each representing
    /// a box of eggs in the kitchen.
    @NSManaged public var parent: AbstractIngredient

    /// The location in the kitchen where this ingredient resides.
    public var location: Location {
        get {
            return Location(rawValue: properlyGetPrimitiveValue(forKey: "location") as! Int)!
        }
        set {
            properlySetPrimitiveValue(newValue.rawValue, forKey: "location")
        }
    }
}

// MARK: Generated accessors for meals
extension Ingredient {

    @objc(addMealsObject:)
    @NSManaged public func addToMeals(_ value: Meal)

    @objc(removeMealsObject:)
    @NSManaged public func removeFromMeals(_ value: Meal)

    @objc(addMeals:)
    @NSManaged public func addToMeals(_ values: NSSet)

    @objc(removeMeals:)
    @NSManaged public func removeFromMeals(_ values: NSSet)

}

extension Ingredient : Identifiable {

}

extension Ingredient {
    convenience init(context: NSManagedObjectContext, name: String, expiryDate: Date?, location: Location) {
        self.init(context: context)
        self.name = name
        self.expiryDate = expiryDate
        self.location = location
    }
    
    convenience init(context: NSManagedObjectContext, parent: AbstractIngredient, expiryDate: Date?, location: Location) {
        self.init(context: context)
        self.name = parent.name
        self.parent = parent
        self.expiryDate = expiryDate
        self.location = location
    }
}
