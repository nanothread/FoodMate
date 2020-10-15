//
//  Ingredient+CoreDataClass.swift
//  FoodMate
//
//  Created by Andrew Glen on 03/10/2020.
//
//

import Foundation
import CoreData

@objc(Ingredient)
/// Represents an actual ingredient in the kitchen, always tied to an instance of `AbstractIngredient` (which
/// represents the idea of an ingredient in general).
public class Ingredient: NSManagedObject {

}
