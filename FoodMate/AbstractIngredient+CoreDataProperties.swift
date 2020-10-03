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

    @NSManaged public var name: String
    @NSManaged public var children: Set<Ingredient>

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
