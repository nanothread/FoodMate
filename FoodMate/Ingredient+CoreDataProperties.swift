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

    @NSManaged public var name: String
    @NSManaged public var expiryDate: Date?
    public var location: Location {
        set {
            willChangeValue(forKey: "location")
            setPrimitiveValue(newValue.rawValue, forKey: "location")
            didChangeValue(forKey: "location")
        }
        get {
            willAccessValue(forKey: "location")
            let raw = primitiveValue(forKey: "location") as! Int
            didAccessValue(forKey: "location")
            return Location(rawValue: raw)!
        }
    }
    @NSManaged public var meals: Set<Meal>
    @NSManaged public var parent: AbstractIngredient

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
}
