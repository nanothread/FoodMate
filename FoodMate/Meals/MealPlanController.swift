//
//  MealPlanController.swift
//  FoodMate
//
//  Created by Andrew Glen on 11/10/2020.
//

import SwiftUI
import UIKit

/// Configures the meal planner and performs planner-related actions on the data model.
struct MealPlanController: UIViewControllerRepresentable {
    typealias UIViewControllerType = UINavigationController
    static let dayOffsets = Array(-1 ... 7)
    
    /// When non-nil, the user will be adding a meal into this space.
    @Binding var creatingMealSpace: MealSpace?
    
    /// Maintains the meal planner collection view.
    @StateObject var viewManager = CollectionViewManager(dayOffsets: Self.dayOffsets)
    
    /// All the meals that have been scheduled inside the planner's date range.
    @FetchRequest(entity: Meal.entity(),
                  sortDescriptors: [],
                  predicate: NSPredicate(format: "scheduledDay > %@", argumentArray: [
                    Date().adding(days: -1) // TODO: Refine this to start of day to include all meals on day -1.
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
                    cell.host(rootView: mealRowView(forMeal: meal, indexPath: indexPath))
                case .empty(let space):
                    cell.host(rootView: EmptyMealSlotView(slot: space.slot.title, action: {
                        creatingMealSpace = space
                    }))
                }
            },
            deleteMeal: deleteMeal,
            saveChanges: { saveContext() }
        )
        
        let navigationController = UINavigationController(rootViewController: viewManager.collectionViewController)
        viewManager.collectionViewController.title = "Meal Plan"
        navigationController.navigationBar.prefersLargeTitles = true
        navigationController.navigationItem.largeTitleDisplayMode = .always
        
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
    
    /// A view in which to display a scheduled meal.
    func mealRowView(forMeal meal: Meal, indexPath: IndexPath) -> some View {
        MealRow(meal: meal)
            .contextMenu {
                Button {
                    bringForwardMeals(afterAndIncluding: meal)
                } label: {
                    Label("Bring \(meal.scheduledSlot.pluralTitle) Forward", systemImage: "arrow.up")
                }.disabled(
                    indexPath.section == 0 ||
                    meals.contains(where: {
                        $0.scheduledSlot == meal.scheduledSlot &&
                        Date().adding(days: Self.dayOffsets[indexPath.section - 1]).isInSameDay(as: $0.scheduledDay)
                    })
                )
                
                Button {
                    sendBackMeals(afterAndIncluding: meal)
                } label: {
                    Label("Send \(meal.scheduledSlot.pluralTitle) Back", systemImage: "arrow.down")
                }
            }
            .background(Color(.secondarySystemGroupedBackground))
    }
    
    /// Brings `meal` and subsequent meals in the same slot forwards by a day.
    ///
    /// - TODO: Ensure that applying this function will not cause two meals to have the same `MealSpace`.
    func bringForwardMeals(afterAndIncluding meal: Meal) {
        meals
            .filter {
                $0.scheduledSlot == meal.scheduledSlot &&
                Calendar.current.compare($0.scheduledDay, to: meal.scheduledDay, toGranularity: .day) != .orderedAscending
            }
            .forEach { meal in
                meal.scheduledDay = meal.scheduledDay.adding(days: -1)
            }
        
        saveContext(actionDescription: "bring meals forward")
    }
    
    /// Sends `meal` and subsequent meals in the same slot back by a day. This creates in the space currently holding `meal.`
    func sendBackMeals(afterAndIncluding meal: Meal) {
        meals
            .filter {
                $0.scheduledSlot == meal.scheduledSlot &&
                Calendar.current.compare($0.scheduledDay, to: meal.scheduledDay, toGranularity: .day) != .orderedAscending
            }
            .forEach { meal in
                meal.scheduledDay = meal.scheduledDay.adding(days: 1)
            }
        
        saveContext(actionDescription: "send meals back")
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
    
    func saveContext(actionDescription: String = "save context") {
        do {
            try self.context.save()
        } catch {
            Logger.coreData.error("MealPlanController failed to \(actionDescription) : \(error.localizedDescription)")
        }
    }
}
