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

    /// The ingredient's name. This should be (but is not guaranteed to be) unique across all instances.
    @NSManaged public var name: String
    /// The set of concrete 'instances' of this ingredient that are actually in the kitchen.
    @NSManaged public var children: Set<Ingredient>
    /// The set of shopping items that have been created to purchase this ingredient.
    @NSManaged public var shoppingItems: Set<ShoppingItem>
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

extension AbstractIngredient {
    /// An ID that uniquely identifies this instance, incorporating the number of shopping items attached to it. If the number of shopping items changes, this ID will also change.
    var shoppingItemDependentID: String {
        "\(objectID.uriRepresentation().absoluteString):\(shoppingItems.count)"
    }
}
