//
//  FoodMateApp.swift
//  FoodMate
//
//  Created by Andrew Glen on 03/10/2020.
//

import SwiftUI

@main
struct FoodMateApp: App {
    @StateObject var searchProvider = SearchProvider(context: PersistenceController.shared.container.viewContext)
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContainerView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(searchProvider)
                .onAppear {
                    #if DEBUG
                    if CommandLine.arguments.contains("-clearCoreData") {
                        Logger.coreData.info("Deleting all Core Data entities...")
                        do {
                            let context = PersistenceController.shared.container.viewContext
                            (try context.fetch(Meal.fetchRequest()) as! [Meal]).forEach(context.delete)
                            (try context.fetch(Ingredient.fetchRequest()) as! [Ingredient]).forEach(context.delete)
                            (try context.fetch(AbstractIngredient.fetchRequest()) as! [AbstractIngredient]).forEach(context.delete)
                            (try context.fetch(ShoppingItem.fetchRequest()) as! [ShoppingItem]).forEach(context.delete)

                            try context.save()
                            Logger.coreData.info("Done!")
                        } catch {
                            Logger.coreData.error("Failed to clear Core Data: \(error.localizedDescription)")
                        }
                    }
                    #endif
                }
        }
    }
}
