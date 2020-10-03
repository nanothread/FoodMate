//
//  MealRow.swift
//  FoodMate
//
//  Created by Andrew Glen on 03/10/2020.
//

import SwiftUI

struct MealRow: View {
    var name: String
    
    var body: some View {
        Text(name)
    }
}

struct MealRow_Previews: PreviewProvider {
    static var previews: some View {
        MealRow(name: "Carbonara")
    }
}
