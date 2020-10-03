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

    @State private var isAddingNewIngredients = false
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Pantry")) {
                    
                }
                
                Section(header: Text("Fridge")) {
                    
                }
                
                Section(header: Text("Freezer")) {
                    
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
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        IngredientsView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
