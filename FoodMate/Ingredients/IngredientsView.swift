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
        ingredients.filter { $0.location == location }.sorted {
            switch ($0.expiryDate, $1.expiryDate) {
            case (.some(let f), .some(let s)): return f < s
            case (.some(_), .none): return true
            case (.none, .some(_)): return false
            case (.none, .none): return $0.name < $1.name
            }
        }
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
                    .imageScale(.large)
            })
            .sheet(isPresented: $isAddingNewIngredients) {
                NewIngredientView()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        IngredientsView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
