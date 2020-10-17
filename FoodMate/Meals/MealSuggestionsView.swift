//
//  MealSuggestionsView.swift
//  FoodMate
//
//  Created by Andrew Glen on 17/10/2020.
//

import SwiftUI
import CoreData

struct MealSuggestionsView: View {
    @StateObject var provider: MealSuggestionProvider
    
    init(context: NSManagedObjectContext) {
        _provider = StateObject(wrappedValue: MealSuggestionProvider(context: context))
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
                        Text(meal.name)
                    }
                }
            }
        }
        .listStyle(InsetGroupedListStyle())
        .navigationTitle("Meal Suggestions")
    }
}

struct MealSuggestionsWrapperView: View {
    @Environment(\.managedObjectContext) private var context
    
    var body: some View {
        MealSuggestionsView(context: context)
    }
}
