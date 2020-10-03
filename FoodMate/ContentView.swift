//
//  ContentView.swift
//  FoodMate
//
//  Created by Andrew Glen on 03/10/2020.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var context

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
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
