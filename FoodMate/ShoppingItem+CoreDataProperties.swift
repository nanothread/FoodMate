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

    @NSManaged public var name: String
    @NSManaged public var expiryDate: Date?
    @NSManaged public var ingredient: AbstractIngredient?

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
