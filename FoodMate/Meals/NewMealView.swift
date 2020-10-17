//
//  NewMealView.swift
//  FoodMate
//
//  Created by Andrew Glen on 03/10/2020.
//

import SwiftUI
import CoreData

/// An interface for the user to create and add ingredients to a new meal.
struct NewMealView: View {
    var space: MealSpace
    @EnvironmentObject private var searchProvider: SearchProvider
    
    @State private var name: String = ""
    @State private var ingredient: String = ""
    
    @State private var ingredientSearchResults = [AbstractIngredient]()
    @State private var mealSearchResults = [Meal]()
    @State private var ingredients = [AbstractIngredient]()
    
    @Environment(\.presentationMode) private var presentation
    @Environment(\.managedObjectContext) private var context

    @StateObject private var notificationManager = NotificationManager()
    @StateObject private var store = CancellableStore()
    
    func saveMeal() {
        let meal = Meal(context: context, name: name, space: space, ingredients: Set(ingredients))
        
        do {
            try context.save()
            attemptToScheduleNotificationsFor(meal: meal) {
                presentation.wrappedValue.dismiss()
            }
        } catch {
            Logger.coreData.error("NewMealView failed to save meal: \(error.localizedDescription)")
        }
    }
    
    func saveDuplicateOf(meal: Meal) {
        _ =  Meal(context: context, name: meal.name, space: space, ingredients: meal.ingredients)

        do {
            try context.save()
            attemptToScheduleNotificationsFor(meal: meal) {
                presentation.wrappedValue.dismiss()
            }
        } catch {
            Logger.coreData.error("NewMealView failed to save meal: \(error.localizedDescription)")
        }
    }
    
    func attemptToScheduleNotificationsFor(meal: Meal, completion: @escaping () -> Void) {
        if let publisher = notificationManager.considerSettingNotification(for: meal) {
            publisher
                .receive(on: DispatchQueue.main)
                .sink { result in
                    if case .failure(let error) = result {
                        Logger.notifications.error("Failed to schedule notifications: \(error.localizedDescription)")
                    } else {
                        Logger.notifications.info("Scheduled notifications successfully")
                    }
                    
                    completion()
                } receiveValue: {  _ in }
                .store(in: &store.cancellables)
        } else {
            completion()
        }
    }
    
    func addIngredient(named name: Binding<String>) {
        defer {
            name.wrappedValue = ""
        }
        
        let trimmedName = name.wrappedValue.trimmingCharacters(in: .whitespaces)
        guard !trimmedName.isEmpty else {
            return
        }
        
        ingredients.append(searchProvider.findOrMakeAbstractIngredient(named: trimmedName))
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Name", text: $name)
                        .onChange(of: name) { name in
                            mealSearchResults = searchProvider.getMealsWithDistinctNames(matching: name)
                        }
                    
                    ForEach(mealSearchResults) { meal in
                        Button {
                            saveDuplicateOf(meal: meal)
                        } label: {
                            Label(meal.name, systemImage: "magnifyingglass")
                        }
                    }
                    
                    NavigationLink(destination: MealSuggestionsView(context: context, addMeal: saveDuplicateOf)) {
                        Text("Suggestions")
                    }
                    .foregroundColor(.accentColor)
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
                    
                    if !ingredient.trimmingCharacters(in: .whitespaces).isEmpty {
                        Button {
                            addIngredient(named: $ingredient)
                        } label: {
                            Label("Add \(ingredient.trimmingCharacters(in: .whitespaces).firstUppercased)", systemImage: "plus")
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
                        saveMeal()
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
        NewMealView(space: MealSpace(day: Date(), slot: .lunch))
    }
}
