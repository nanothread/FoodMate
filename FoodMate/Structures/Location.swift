//
//  Location.swift
//  FoodMate
//
//  Created by Andrew Glen on 03/10/2020.
//

import Foundation

/// A location in the kitchen where an ingredient might be stored.
public enum Location: Int, CaseIterable {
    case pantry
    case fridge
    case freezer
    
    /// The user-facing name of the location.
    var title: String {
        switch self {
        case .pantry: return NSLocalizedString("Pantry", comment: "Storing non-chilled goods.")
        case .fridge: return NSLocalizedString("Fridge", comment: "A refridgerator.")
        case .freezer: return NSLocalizedString("Freezer", comment: "Storing frozen goods.")
        }
    }
}

extension Location: Identifiable {
    public var id: Int { rawValue }
}
