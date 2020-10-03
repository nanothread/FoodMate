//
//  NSManagedObject+Extensions.swift
//  FoodMate
//
//  Created by Andrew Glen on 03/10/2020.
//

import Foundation
import CoreData

extension NSManagedObject {
    func properlySetPrimitiveValue(_ value: Any?, forKey key: String) {
        willChangeValue(forKey: key)
        setPrimitiveValue(value, forKey: key)
        didChangeValue(forKey: key)
    }
    
    func properlyGetPrimitiveValue(forKey key: String) -> Any? {
        defer {
            didAccessValue(forKey: key)
        }
        
        willAccessValue(forKey: key)
        return primitiveValue(forKey: key)
    }
}
