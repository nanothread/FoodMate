//
//  NewIngredientView.swift
//  FoodMate
//
//  Created by Andrew Glen on 03/10/2020.
//

import SwiftUI
import os

struct NewIngredientView: View {
    @State private var name: String = ""
    @State private var expiryDate: Date = Date()
    @State private var rawLocation: Int = Location.pantry.rawValue
    @State private var ingredientSearchResults = [AbstractIngredient]()
    @State private var selectedParent: AbstractIngredient?
    
    @State var ingredients = [Ingredient]()
    @Environment(\.managedObjectContext) private var context
    @Environment(\.presentationMode) private var presentation
    @EnvironmentObject private var searchProvider: SearchProvider
     
    func recordIngredient() {
        if let parent = selectedParent {
            ingredients.append(
                Ingredient(context: context,
                           parent: parent,
                           expiryDate: Calendar.current.isDateInToday(expiryDate) ? nil : expiryDate,
                           location: Location(rawValue: rawLocation)!)
            )
        } else {
            let ingredient = Ingredient(context: context,
                                        name: name,
                                        expiryDate: Calendar.current.isDateInToday(expiryDate) ? nil : expiryDate,
                                        location: Location(rawValue: rawLocation)!)
            ingredients.append(ingredient)
            
            let abstract = AbstractIngredient(context: context)
            abstract.name = name
            ingredient.parent = abstract
        }
        
        name = ""
        expiryDate = Date()
        rawLocation = Location.pantry.rawValue
    }
    
    func saveChanges() {
        do {
            try context.save()
        } catch {
            Logger.coreData.error("NewIngredientView failed to save changes: \(error.localizedDescription)")
        }
    }
    
    func deleteRecordedIngredients(at indices: IndexSet) {
        // TODO: Delete parents with no child ingredients now
        indices.map { ingredients[$0] }.forEach(context.delete)
        ingredients.remove(atOffsets: indices)
    }
    
    var body: some View {
        NavigationView {
            VStack {
                Form {
                    Section {
                        TextField("Name", text: $name)
                            .onChange(of: name) { name in
                                if selectedParent == nil {
                                    ingredientSearchResults = searchProvider.getAbstractIngredients(matching: name)
                                } else {
                                    selectedParent = nil
                                }
                            }
                        
                        ForEach(ingredientSearchResults) { ingredient in
                            Button {
                                selectedParent = ingredient
                                name = ingredient.name
                                ingredientSearchResults = []
                            } label: {
                                Label(ingredient.name, systemImage: "magnifyingglass")
                            }
                        }
                        
                        DatePicker("Expiry Date", selection: $expiryDate, displayedComponents: .date)
                        Picker("Location", selection: $rawLocation) {
                            ForEach(Location.allCases.map(\.rawValue), id: \.self) { value in
                                Text(Location(rawValue: value)!.title)
                                    .tag(value)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }
                    
                    Section {
                        HStack {
                            Button {
                                recordIngredient()
                            } label: {
                                Text("Save")
                            }
                            .frame(maxWidth: .infinity)
                            .disabled(
                                name.trimmingCharacters(in: .whitespaces).isEmpty
                            )
                        }
                    }
                    
                    Section {
                        ForEach(ingredients) { ingredient in
                            IngredientRow(name: ingredient.name, expiryDate: ingredient.expiryDate)
                        }
                        .onDelete(perform: deleteRecordedIngredients)
                    }
                }
            }
            .navigationTitle("New Ingredient")
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
                        saveChanges()
                        presentation.wrappedValue.dismiss()
                    } label: {
                        Text("Done")
                    }
                    .disabled(
                        ingredients.isEmpty
                    )
            )
        }
    }
}




struct NewIngredientView_Previews: PreviewProvider {
    static let ingredients = [
        Ingredient(context: PersistenceController.preview.container.viewContext,
                   name: "Parmesan",
                   expiryDate: nil,
                   location: .fridge)
    ]
    
    static var previews: some View {
        NewIngredientView()
    }
}
