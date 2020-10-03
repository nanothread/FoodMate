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
    
    @State var ingredients = [Ingredient]()
    @Environment(\.managedObjectContext) private var context
    @Environment(\.presentationMode) private var presentation
     
    func recordIngredient() {
        ingredients.append(
            Ingredient(context: context,
                       name: name,
                       expiryDate: Calendar.current.isDateInToday(expiryDate) ? nil : expiryDate,
                       location: Location(rawValue: rawLocation)!)
        )
        
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
    
    var body: some View {
        NavigationView {
            VStack {
                Form {
                    Section {
                        TextField("Name", text: $name)
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
                    }
                }
            }
            .navigationTitle("New Ingredient")
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
