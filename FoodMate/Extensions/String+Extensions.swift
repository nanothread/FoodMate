//
//  String+Extensions.swift
//  FoodMate
//
//  Created by Andrew Glen on 03/10/2020.
//

import Foundation

extension String {
    /// Uppercases the first character of the string.
    var firstUppercased: String {
        prefix(1).uppercased() + dropFirst()
    }
}
