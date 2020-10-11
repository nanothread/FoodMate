//
//  MealPlanController.swift
//  FoodMate
//
//  Created by Andrew Glen on 11/10/2020.
//

import SwiftUI
import UIKit

struct MealPlanController: UIViewControllerRepresentable {
    typealias UIViewControllerType = UINavigationController
    static let dayOffsets = Array(-1 ... 7)
    
    @Binding var creatingMealSpace: MealSpace?
    
    @StateObject var viewManager = CollectionViewManager(dayOffsets: Self.dayOffsets)
    @FetchRequest(entity: Meal.entity(),
                  sortDescriptors: [],
                  predicate: NSPredicate(format: "scheduledDay > %@", argumentArray: [
                    Date().adding(days: -1)
                  ]),
                  animation: nil)
    private var meals: FetchedResults<Meal>
    
    @Environment(\.managedObjectContext) private var context
    
    func makeUIViewController(context: Context) -> UIViewControllerType {
        viewManager.configure(
            meals: Set(meals),
            cellRegistration: CollectionViewManager.CellRegistration { cell, indexPath, slotType in
                switch slotType {
                case .filled(let meal):
                    cell.host(rootView: MealRow(meal: meal))
                case .empty(let space):
                    cell.host(rootView: EmptyMealSlotView(slot: space.slot.title, action: {
                        creatingMealSpace = space
                    }))
                }
            },
            deleteMeal: deleteMeal,
            saveChanges: {
                do {
                    try self.context.save()
                } catch {
                    Logger.coreData.error("MealPlanController failed to save context: \(error.localizedDescription)")
                }
            }
        )
        
        let navigationController = UINavigationController(rootViewController: viewManager.collectionViewController)
        viewManager.collectionViewController.title = "Meal Plan"
        navigationController.navigationBar.prefersLargeTitles = true
        
        viewManager.selectMeal = { meal in
            let controller = UIHostingController(rootView: MealDetailView(meal: meal))
            controller.title = meal.name // Fixes SwiftUI Nav Bar title glitch
            navigationController.pushViewController(controller, animated: true)
        }
        
        return navigationController
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        Logger.general.debug("Trying to update meal plan view: \(meals.map(\.name))")
        viewManager.refresh(withMeals: Set(meals))
    }
    
    func deleteMeal(_ meal: Meal) -> Bool {
        do {
            context.delete(meal)
            try context.save()
            return true
        }
        catch {
            Logger.coreData.error("MealPlanController failed to delete meal: \(error.localizedDescription)")
            return false
        }
    }
}
