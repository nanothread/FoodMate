//
//  Location.swift
//  FoodMate
//
//  Created by Andrew Glen on 03/10/2020.
//

import Foundation

@objc public enum Location: Int, CaseIterable {
    case pantry
    case fridge
    case freezer
    
    var title: String {
        switch self {
        case .pantry: return "Pantry"
        case .fridge: return "Fridge"
        case .freezer: return "Freezer"
        }
    }
}
