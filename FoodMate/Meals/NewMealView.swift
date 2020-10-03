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
    
    @Environment(\.presentationMode) private var presentation
    
    func saveMeal() {
        
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Name", text: $name)
                }
                
                Section(header: Text("Ingredients")) {
                    TextField("Search", text: $ingredient)
                        .onChange(of: ingredient) { ingredient in
                            ingredientSearchResults = searchProvider.getAbstractIngredients(matching: ingredient)
                        }
                    
                    ForEach(ingredientSearchResults) { ingredient in
                        Button {
                            ingredients.insert(ingredient, at: 0)
                            self.ingredient = ""
                        } label: {
                            Label(ingredient.name, systemImage: "magnifyingglass")
                        }
                    }
                    
                    ForEach(ingredients) { ingredient in
                        Text(ingredient.name)
                    }
                    .onDelete { ingredients.remove(atOffsets: $0) }
                }
            }
            .navigationTitle("New Meal")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading:
                    Button {
                        presentation.wrappedValue.dismiss()
                    } label: {
                        Text("Cancel")
                    },
                trailing:
                    Button {
                        // TODO save changes
                        presentation.wrappedValue.dismiss()
                    } label: {
                        Text("Done")
                    }
                    .disabled(
                        ingredients.isEmpty || name.trimmingCharacters(in: .whitespaces).isEmpty
                    )
            )
        }
    }
}

struct NewMealView_Previews: PreviewProvider {
    static var previews: some View {
        NewMealView(slot: .lunch)
    }
}
