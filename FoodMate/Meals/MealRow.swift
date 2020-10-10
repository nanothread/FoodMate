//
//  MealRow.swift
//  FoodMate
//
//  Created by Andrew Glen on 03/10/2020.
//

import SwiftUI

struct MealRow: View {
    private enum IngredientLocation: String, CaseIterable, Identifiable {
        case shoppingList, kitchen
        
        var id: String { rawValue }
        
        var systemImage: String {
            switch self {
            case .shoppingList: return "cart"
            case .kitchen: return "cube.box"
            }
        }
    }
    
    var meal: Meal
    
    private func countIngredients(in location: IngredientLocation) -> Int {
        switch location {
        case .shoppingList: return meal.ingredients.filter { !$0.shoppingItems.isEmpty }.count
        case .kitchen: return meal.ingredients.filter { !$0.children.isEmpty }.count
        }
    }
    
    var body: some View {
        NavigationLink(destination: MealDetailView(meal: meal)) {
            HStack {
                if meal.ingredients.flatMap(\.children).contains(where: { $0.location == .freezer }) {
                    Image(systemName: "snow")
                        .foregroundColor(.blue)
                }
                Text(meal.name)
                
                Spacer()
                
                Group {
                    ForEach(IngredientLocation.allCases) { location in
                        HStack(spacing: 4) {
                            Text("\(countIngredients(in: location))")
                            Image(systemName: location.systemImage)
                        }
                    }
                }
                .foregroundColor(.gray)
                .imageScale(.small)
                .font(.callout)
            }
        }
    }
}
