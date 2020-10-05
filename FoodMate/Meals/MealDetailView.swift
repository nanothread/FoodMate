//
//  MealDetailView.swift
//  FoodMate
//
//  Created by Andrew Glen on 05/10/2020.
//

import SwiftUI

struct MealDetailView: View {
    @Environment(\.managedObjectContext) private var context
    
    @ObservedObject var meal: Meal
    
    var ingredients: [AbstractIngredient] {
        Array(meal.ingredients).sorted { $0.name < $1.name }
    }
    
    var ingredientsOutsideShoppingList: Set<AbstractIngredient> {
        meal.ingredients.filter { $0.shoppingItems.isEmpty }
    }
    
    func deleteIngredients(at offsets: IndexSet) {
        offsets.map { ingredients[$0] }.forEach(context.delete)
        saveContext(actionDescription: "delete ingredients")
    }
    
    func addRemainingIngredientsToShoppingList() {
        meal.objectWillChange.send()
        
        for ingredient in ingredientsOutsideShoppingList {
            let item = ShoppingItem(context: context, name: ingredient.name, status: .pending)
            item.ingredient = ingredient
        }
        
        saveContext(actionDescription: "add remaining items to shopping list")
    }
    
    func addIngredientToShoppingList(ingredient: AbstractIngredient) {
        meal.objectWillChange.send()
        let item = ShoppingItem(context: context, name: ingredient.name, status: .pending)
        item.ingredient = ingredient
        saveContext(actionDescription: "add to shopping list")
    }
    
    func removeIngredientFromShoppingList(ingredient: AbstractIngredient) {
        meal.objectWillChange.send()
        ingredient.shoppingItems.forEach(context.delete)
        saveContext(actionDescription: "remove from shopping list")
    }
    
    func removeAllIngredientsFromShoppingList() {
        meal.objectWillChange.send()
        meal.ingredients.flatMap(\.shoppingItems).forEach(context.delete)
        saveContext(actionDescription: "remove all ingredients from shopping list")
    }
    
    func saveContext(actionDescription: String) {
        do {
            try context.save()
        } catch {
            Logger.coreData.error("MealDetailView failed to \(actionDescription): \(error.localizedDescription)")
        }
    }
        
    var body: some View {
        List {
            Section(header: Text("Ingredients")) {
                ForEach(ingredients, id: \.shoppingItemDependentID) { ingredient in
                    HStack {
                        Text(ingredient.name)
                        Spacer()
                        
                        if ingredientsOutsideShoppingList.contains(ingredient) {
                            Button {
                                addIngredientToShoppingList(ingredient: ingredient)
                            } label: {
                                Image(systemName: "cart.badge.plus")
                            }
                        } else {
                            Button {
                                removeIngredientFromShoppingList(ingredient: ingredient)
                            } label: {
                                Image(systemName: "cart.badge.minus")
                                    .foregroundColor(.red)
                            }
                        }
                    }
                    .id(ingredient.shoppingItemDependentID)
                }
                .onDelete(perform: deleteIngredients)
            }
            
            Section {
                if ingredientsOutsideShoppingList.isEmpty {
                    Button(action: removeAllIngredientsFromShoppingList) {
                        Label("Remove All", systemImage: "trash")
                            .foregroundColor(.red)
                    }
                } else {
                    Button(action: addRemainingIngredientsToShoppingList) {
                        Label(ingredientsOutsideShoppingList.count == meal.ingredients.count ? "Add All" : "Add Remaining", systemImage: "plus")
                    }
                }
            }
        }
        .listStyle(InsetGroupedListStyle())
        .navigationTitle(meal.name)
    }
}
