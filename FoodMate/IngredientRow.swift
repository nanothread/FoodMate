//
//  IngredientRow.swift
//  FoodMate
//
//  Created by Andrew Glen on 03/10/2020.
//

import SwiftUI

struct IngredientRow: View {
    var name: String
    var expiryDate: Date
    
    private var daysUntilExpiry: Int {
        Calendar.current.dateComponents([.day], from: Date(), to: expiryDate).day!
    }
    
    var body: some View {
        HStack {
            Text(name)
            Spacer()
            Text("\(daysUntilExpiry) days")
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
