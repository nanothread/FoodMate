//
//  NewMealView.swift
//  FoodMate
//
//  Created by Andrew Glen on 03/10/2020.
//

import SwiftUI
import CoreData

struct NewMealView: View {
    var slot: MealSlot
    @EnvironmentObject private var searchProvider: SearchProvider
    
    @State private var name: String = ""
    @State private var ingredient: String = ""
    
    @State private var ingredientSearchResults = [AbstractIngredient]()
    @State private var ingredients = [AbstractIngredient]()
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Name", text: $name)
                }
                
                Section(header: Text("Ingredients")) {
                    TextField("Search", text: $ingredient)
                        .onChange(of: ingredient) { ingredient in
                            ingredientSearchResults = searchProvider.getAbstractIngredients(matching: name)
                        }
                    
                    Button {
                        
                    } label: {
                        Label("Add Ingredient", systemImage: "plus")
                    }
                }
            }
            .navigationTitle("New Meal")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct NewMealView_Previews: PreviewProvider {
    static var previews: some View {
        NewMealView(slot: .lunch)
    }
}
