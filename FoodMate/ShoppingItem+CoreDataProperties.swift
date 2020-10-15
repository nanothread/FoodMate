//
//  ShoppingItem+CoreDataProperties.swift
//  FoodMate
//
//  Created by Andrew Glen on 03/10/2020.
//
//

import Foundation
import CoreData


extension ShoppingItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ShoppingItem> {
        return NSFetchRequest<ShoppingItem>(entityName: "ShoppingItem")
    }

    /// The name the user has given this shopping item.
    @NSManaged public var name: String
    /// The date this shopping item was added to the list.
    @NSManaged public var dateCreated: Date
    /// The expiry date of the food item that this shopping item represents.
    @NSManaged public var expiryDate: Date?
    /// The ingredient that this shopping item represents. Optional because the user
    /// may add non-ingredient items (like kitchen foil) to their shopping list.
    @NSManaged public var ingredient: AbstractIngredient?

    /// The current status of this shopping item in the list.
    public var status: ShoppingItemStatus {
        get {
            ShoppingItemStatus(rawValue: properlyGetPrimitiveValue(forKey: "status") as! String)!
        }
        set {
            properlySetPrimitiveValue(newValue.rawValue, forKey: "status")
        }
    }
}

extension ShoppingItem : Identifiable {

}

extension ShoppingItem {
    convenience init(context: NSManagedObjectContext, name: String, status: ShoppingItemStatus) {
        self.init(context: context)
        self.name = name
        self.dateCreated = Date()
        self.status = status
    }
    
    /// An ID uniquely identifying this instance, taking into account the current status of the
    /// item in the list. If the item's status changes, this ID will change.
    var statusDependentID: String {
        "\(objectID.uriRepresentation().absoluteString):\(status.rawValue)"
    }
}
