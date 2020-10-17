//
//  MealSuggestionsView.swift
//  FoodMate
//
//  Created by Andrew Glen on 17/10/2020.
//

import SwiftUI

struct MealSuggestionsView: View {
    @State private var isShoppingRequired: Bool = true
    
    var body: some View {
        Form {
            Section {
                Toggle("Shopping Required", isOn: $isShoppingRequired)
            }
            
            Section {
                HStack {
                    Spacer()
                    Text("No Results")
                    Spacer()
                }
            }
        }
        .listStyle(InsetGroupedListStyle())
        .navigationTitle("Meal Suggestions")
    }
}

struct MealSuggestionsView_Previews: PreviewProvider {
    static var previews: some View {
        MealSuggestionsView()
    }
}
