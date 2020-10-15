//
//  MealPlanModel.swift
//  FoodMate
//
//  Created by Andrew Glen on 11/10/2020.
//

import UIKit

/// Manages the data source of the meal planner collection view and the drag-and-drop reodering logic.
class MealPlanModel: NSObject {
    typealias DataSource = UICollectionViewDiffableDataSource<DayOffset, MealSlotModel>

    private var cellModels = [DayOffset: [MealSlotModel]]()
    private var currentSchedule = [Meal: MealSpace]()
    private(set) var dayOffsets: [DayOffset]
    var dataSource: DataSource?
    
    var saveMealChanges: () -> Void
    var reloadCollectionView: () -> Void
    
    init(dayOffsets: [DayOffset], saveMealChanges: @escaping () -> Void, reloadCollectionView: @escaping () -> Void) {
        self.dayOffsets = dayOffsets
        self.saveMealChanges = saveMealChanges
        self.reloadCollectionView = reloadCollectionView
    }
    
    /// Checks whether a new set of meals contains any differences to the current set of meals that would require an update of the collection view---i.e. all meals are the same and in the same meal space.
    ///
    /// Prevents uneccesary updates to the collection view that (I think) cause black flickering.
    private func mealsContainDifferencesToCurrentSchedule(_ newMeals: Set<Meal>) -> Bool {
        guard Set(currentSchedule.keys) == newMeals else { return true }
        
        for meal in newMeals {
            guard let oldSpace = currentSchedule[meal] else { return true }
            guard oldSpace.day.isInSameDay(as: meal.scheduledDay) else { return true }
            guard oldSpace.slot == meal.scheduledSlot else { return true }
        }
        
        return false
    }
    
    func refresh(withMeals meals: Set<Meal>) {
        // Prevent unneccesary updates.
        guard cellModels.isEmpty || mealsContainDifferencesToCurrentSchedule(meals) else {
             return
        }
        
        currentSchedule = meals.reduce(into: [:]) { $0[$1] = MealSpace(day: $1.scheduledDay, slot: $1.scheduledSlot) }
        Logger.general.debug("> Actually updating meal plan view")
        
        // Construct model for every row in the planner.
        for offset in dayOffsets {
            let day = Date().adding(days: offset)
            let eligibleMeals = meals.filter { $0.scheduledDay.isInSameDay(as: day) }
            let models: [MealSlotModel] = MealSlot.allCases.map { slot in
                if let meal = eligibleMeals.first(where: { $0.scheduledSlot == slot }) {
                    return .filled(meal)
                } else {
                    return .empty(MealSpace(day: day, slot: slot))
                }
            }
            
            cellModels[offset] = models
        }
        
        // Apply model to collection view.
        var snapshot = NSDiffableDataSourceSnapshot<DayOffset, MealSlotModel>()
        snapshot.appendSections(dayOffsets)
        
        for offset in dayOffsets {
            guard let models = cellModels[offset] else { continue }
            snapshot.appendItems(models, toSection: offset)
        }

        dataSource?.apply(snapshot, completion: reloadCollectionView)
    }
    
    /// Returns the cell model currently at `indexPath`.
    ///
    /// - TODO: Add preconditions for index logic.
    func cellModel(at indexPath: IndexPath) -> MealSlotModel {
        let section = cellModels.keys.sorted()[indexPath.section]
        return cellModels[section]![indexPath.row]
    }
}

extension MealPlanModel: UICollectionViewDragDelegate {
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        guard case .filled(let meal) = cellModel(at: indexPath) else { return [] }
        return [UIDragItem(itemProvider: NSItemProvider(object: meal.objectID.uriRepresentation().absoluteString as NSString))]
    }
}

extension MealPlanModel: UICollectionViewDropDelegate {
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        guard let destination = coordinator.destinationIndexPath else {
            Logger.dragDrop.debug("Drop coordinator destinationIndexPath is nil")
            return
        }
        
        guard let source = coordinator.items.first?.sourceIndexPath,
              case .filled(let selectedMeal) = cellModel(at: source) else {
            Logger.dragDrop.debug("Drop coordinator could not locate source meal")
            return
        }
        
        switch cellModel(at: destination) {
        case .filled(let destinationMeal): // Swap meals
            let sourceSpace = MealSpace(day: selectedMeal.scheduledDay, slot: selectedMeal.scheduledSlot)
            selectedMeal.scheduledDay = destinationMeal.scheduledDay
            selectedMeal.scheduledSlot = destinationMeal.scheduledSlot
            destinationMeal.scheduledDay = sourceSpace.day
            destinationMeal.scheduledSlot = sourceSpace.slot
        case .empty(let space): // Move meal
            selectedMeal.scheduledDay = space.day
            selectedMeal.scheduledSlot = space.slot
        }
        
        saveMealChanges()
    }
    
    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        .init(operation: .move, intent: .insertIntoDestinationIndexPath)
    }
}
