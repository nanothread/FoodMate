//
//  IngredientRow.swift
//  FoodMate
//
//  Created by Andrew Glen on 03/10/2020.
//

import SwiftUI

/// Displays an ingredient alongside a countdown until expiry.
struct IngredientRow: View {
    var name: String
    var expiryDate: Date?
    
    private var daysUntilExpiry: Int? {
        guard let date = expiryDate else { return nil }
        return Calendar.current.dateComponents([.day], from: Date(), to: date).day!
    }
    
    var body: some View {
        HStack {
            Text(name)
            
            if let days = daysUntilExpiry {
                Spacer()
                Text("\(days) days")
            }
        }
    }
}

struct IngredientRow_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            IngredientRow(name: "Parmesan", expiryDate: Date().addingTimeInterval(3 * 24 * 3600))
        }
    }
}
