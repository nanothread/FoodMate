//
//  AbstractIngredient+CoreDataProperties.swift
//  FoodMate
//
//  Created by Andrew Glen on 03/10/2020.
//
//

import Foundation
import CoreData


extension AbstractIngredient {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<AbstractIngredient> {
        return NSFetchRequest<AbstractIngredient>(entityName: "AbstractIngredient")
    }

    @NSManaged public var name: String?
    @NSManaged public var meals: NSSet?
    @NSManaged public var children: NSSet?

}

// MARK: Generated accessors for meals
extension AbstractIngredient {

    @objc(addMealsObject:)
    @NSManaged public func addToMeals(_ value: AbstractMeal)

    @objc(removeMealsObject:)
    @NSManaged public func removeFromMeals(_ value: AbstractMeal)

    @objc(addMeals:)
    @NSManaged public func addToMeals(_ values: NSSet)

    @objc(removeMeals:)
    @NSManaged public func removeFromMeals(_ values: NSSet)

}

// MARK: Generated accessors for children
extension AbstractIngredient {

    @objc(addChildrenObject:)
    @NSManaged public func addToChildren(_ value: Ingredient)

    @objc(removeChildrenObject:)
    @NSManaged public func removeFromChildren(_ value: Ingredient)

    @objc(addChildren:)
    @NSManaged public func addToChildren(_ values: NSSet)

    @objc(removeChildren:)
    @NSManaged public func removeFromChildren(_ values: NSSet)

}

extension AbstractIngredient : Identifiable {

}
