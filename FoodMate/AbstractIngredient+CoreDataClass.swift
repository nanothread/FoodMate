//
//  AbstractIngredient+CoreDataClass.swift
//  FoodMate
//
//  Created by Andrew Glen on 03/10/2020.
//
//

import Foundation
import CoreData

@objc(AbstractIngredient)
/// Represents a unique ingredient in the world, for example, 'Bacon' or 'Eggs'. This may be associated with many meals and there may be multiple instances of this ingredient in a kitchen (which will take the `Ingredient` type).
public class AbstractIngredient: NSManagedObject {

}
