//
//  ShoppingItemStatus.swift
//  FoodMate
//
//  Created by Andrew Glen on 03/10/2020.
//

import Foundation

/// The status of an item in the shopping list.
public enum ShoppingItemStatus: String {
    /// Items that are yet to be checked off.
    case pending
    /// Items that have been checked off and that are waiting to be sorted.
    case completed
}
