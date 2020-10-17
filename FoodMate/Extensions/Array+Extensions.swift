//
//  Array+Extensions.swift
//  FoodMate
//
//  Created by Andrew Glen on 17/10/2020.
//

import Foundation

extension Array {
    /// Returns an array of elements with unique values at the given KeyPath. The first item that matches the KeyPath is kept and the remaining items are discarded.
    /// - Complexity: O(N) time & space.
    func removingDuplicates<Target: Hashable>(of keyPath: KeyPath<Element, Target>) -> Self {
        var visitedItems = Set<Target>()
        var result = [Element]()
        
        for item in self where !visitedItems.contains(item[keyPath: keyPath]) {
            result.append(item)
            visitedItems.insert(item[keyPath: keyPath])
        }
        
        return result
    }
}

