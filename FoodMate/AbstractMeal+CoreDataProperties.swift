//
//  AbstractMeal+CoreDataProperties.swift
//  FoodMate
//
//  Created by Andrew Glen on 03/10/2020.
//
//

import Foundation
import CoreData


extension AbstractMeal {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<AbstractMeal> {
        return NSFetchRequest<AbstractMeal>(entityName: "AbstractMeal")
    }

    @NSManaged public var name: String
    @NSManaged public var ingredients: Set<AbstractIngredient>
    @NSManaged public var children: Set<Meal>

}

// MARK: Generated accessors for ingredients
extension AbstractMeal {

    @objc(addIngredientsObject:)
    @NSManaged public func addToIngredients(_ value: AbstractIngredient)

    @objc(removeIngredientsObject:)
    @NSManaged public func removeFromIngredients(_ value: AbstractIngredient)

    @objc(addIngredients:)
    @NSManaged public func addToIngredients(_ values: NSSet)

    @objc(removeIngredients:)
    @NSManaged public func removeFromIngredients(_ values: NSSet)

}

// MARK: Generated accessors for children
extension AbstractMeal {

    @objc(addChildrenObject:)
    @NSManaged public func addToChildren(_ value: Meal)

    @objc(removeChildrenObject:)
    @NSManaged public func removeFromChildren(_ value: Meal)

    @objc(addChildren:)
    @NSManaged public func addToChildren(_ values: NSSet)

    @objc(removeChildren:)
    @NSManaged public func removeFromChildren(_ values: NSSet)

}

extension AbstractMeal : Identifiable {

}
