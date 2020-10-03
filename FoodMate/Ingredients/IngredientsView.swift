//
//  ContentView.swift
//  FoodMate
//
//  Created by Andrew Glen on 03/10/2020.
//

import SwiftUI
import CoreData

struct IngredientsView: View {
    @Environment(\.managedObjectContext) private var context

    @FetchRequest(entity: Ingredient.entity(), sortDescriptors: [])
    private var ingredients: FetchedResults<Ingredient>
    
    @State private var isAddingNewIngredients = false
    
    private func ingredients(in location: Location) -> [Ingredient] {
        ingredients.filter { $0.location == location }
    }
    
    func deleteIngredients(at indices: IndexSet, in location: Location) {
        let ingredients = self.ingredients(in: location)
        indices.map { ingredients[$0] }.forEach(context.delete)
        
        do {
            try context.save()
        } catch {
            Logger.coreData.error("IngredientsView failed to delete ingredients: \(error.localizedDescription)")
        }
    }
    
    var body: some View {
        NavigationView {
            List {
                ForEach(Location.allCases, id: \.rawValue) { location in
                    Section(header: Text(location.title)) {
                        ForEach(ingredients(in: location)) { ingredient in
                            IngredientRow(name: ingredient.name, expiryDate: ingredient.expiryDate)
                        }
                        .onDelete { indices in
                            deleteIngredients(at: indices, in: location)
                        }
                    }
                }
            }
            .navigationTitle("Ingredients")
            .listStyle(InsetGroupedListStyle())
            .navigationBarItems(trailing: Button {
                isAddingNewIngredients = true
            } label: {
                Image(systemName: "plus")
            })
            .sheet(isPresented: $isAddingNewIngredients) {
                NewIngredientView()
            }
        }
        .onAppear {
//            do {
//                let ings = try context.fetch(AbstractIngredient.fetchRequest()) as! [AbstractIngredient]
//                ings.forEach(context.delete)
//                
//                let ingredients = try context.fetch(Ingredient.fetchRequest()) as! [Ingredient]
//                for ing in ingredients {
//                    context.delete(ing)
//                }
//
//                try context.save()
//            } catch {
//                print("AAAA", error)
//            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        IngredientsView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
