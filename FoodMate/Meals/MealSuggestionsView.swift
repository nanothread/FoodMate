//
//  MealSuggestionsView.swift
//  FoodMate
//
//  Created by Andrew Glen on 17/10/2020.
//

import SwiftUI
import CoreData

/// Displays suggested meals and conrtols to tweak the suggestions.
struct MealSuggestionsView: View {
    @StateObject var provider: MealSuggestionProvider
    
    var addMeal: (Meal) -> Void
    
    init(context: NSManagedObjectContext, addMeal: @escaping (Meal) -> Void) {
        self._provider = StateObject(wrappedValue: MealSuggestionProvider(context: context))
        self.addMeal = addMeal
    }
    
    var body: some View {
        Form {
            Section {
                Toggle("Avoid Going Shopping", isOn: $provider.avoidShopping)
            }
            
            Section(header: Text("Suggestions")) {
                if provider.currentSuggestions.isEmpty {
                    HStack {
                        Spacer()
                        Text("No Results")
                        Spacer()
                    }
                } else {
                    ForEach(provider.currentSuggestions) { meal in
                        Button {
                            addMeal(meal)
                        } label: {
                            Label(meal.name, systemImage: "plus")
                        }
                    }
                }
            }
        }
        .listStyle(InsetGroupedListStyle())
        .navigationTitle("Meal Suggestions")
    }
}
