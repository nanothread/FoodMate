//
//  MealPlanView.swift
//  FoodMate
//
//  Created by Andrew Glen on 03/10/2020.
//

import SwiftUI
import Introspect
import UniformTypeIdentifiers
import CoreData
import UIKit

// TODO: Replace with UICollectionView
// TODO: Add drag and drop reordering to new collection view

// TODO: Edit the ingredients of meals
// TODO: Drag and drop to reorder the plan

struct EmptyMealDropDelegate: DropDelegate {
    var context: NSManagedObjectContext
    var targetSpace: MealSpace
    
    func validateDrop(info: DropInfo) -> Bool {
        true
    }
    
    func dropUpdated(info: DropInfo) -> DropProposal? {
        DropProposal(operation: .move)
    }
    
    func performDrop(info: DropInfo) -> Bool {
        guard let provider = info.itemProviders(for: [.text]).first else {
            return false
        }
        
        provider.loadObject(ofClass: NSString.self) { item, error in
            guard let uri = item as? NSString else {
                Logger.dragDrop.error("EmptyMealDropDelegate failed to load string: \(String(describing: error))")
                return
            }
            
            guard let url = URL(string: uri as String),
                  let id = context.persistentStoreCoordinator?.managedObjectID(forURIRepresentation: url)
            else {
                Logger.dragDrop.error("EmptyMealDropDelegate failed to resolve uri into managed object id.")
                return
            }
            
            do {
                let meal = try context.existingObject(with: id) as! Meal
                meal.scheduledDay = targetSpace.day
                meal.scheduledSlot = targetSpace.slot
                try context.save()
            }
            catch {
                Logger.dragDrop.error("EmptyMealDropDelegate failed to get object for ID or to save changes: \(error.localizedDescription)")
            }
        }
        
        return true
    }
}

class TableViewDropDelegate: NSObject, UITableViewDropDelegate, ObservableObject {
    func tableView(_ tableView: UITableView, performDropWith coordinator: UITableViewDropCoordinator) {
        
    }
    
    func tableView(_ tableView: UITableView, canHandle session: UIDropSession) -> Bool {
        true
    }
    
    func tableView(_ tableView: UITableView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UITableViewDropProposal {
        .init(operation: .move, intent: .insertAtDestinationIndexPath)
    }
}

class TableViewDragDelegate: NSObject, UITableViewDragDelegate, ObservableObject {
    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        [.init(itemProvider: NSItemProvider(object: "sdfsdfsdf" as NSString))]
    }
    
    
}

class CollectionViewDragDelegate: NSObject, UICollectionViewDragDelegate {
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        [.init(itemProvider: NSItemProvider(object: "sdfsdfsdf" as NSString))]
    }
}

class CollectionViewDropDelegate: NSObject, UICollectionViewDropDelegate {
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        
    }
    
    func collectionView(_ collectionView: UICollectionView, canHandle session: UIDropSession) -> Bool {
        true
    }
    
    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        .init(operation: .move, intent: .insertIntoDestinationIndexPath)
    }
}

struct OldMealPlanView: View {
    static let earliestDateOffset = -1
    @Environment(\.managedObjectContext) private var context

    @FetchRequest(entity: Meal.entity(),
                  sortDescriptors: [],
                  predicate: NSPredicate(format: "scheduledDay > %@", argumentArray: [
                    Date().adding(days: Self.earliestDateOffset)
                  ]),
                  animation: nil)
    private var meals: FetchedResults<Meal>
    
    @State private var creatingMealSpace: MealSpace?
    @StateObject private var dropDelegate = TableViewDropDelegate()
    @StateObject private var dragDelegate = TableViewDragDelegate()
    
    func title(for day: Date) -> String {
        let cal = Calendar.current
        if cal.isDateInYesterday(day) {
            return "Yesterday"
        }
        if cal.isDateInToday(day) {
            return "Today"
        }
        if cal.isDateInTomorrow(day) {
            return "Tomorrow"
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE" // e.g "Satuday"
        return formatter.string(from: day)
    }
    
    func meal(on day: Date, for slot: MealSlot) -> Meal? {
        meals.first {
            $0.scheduledSlot == slot &&
            Calendar.current.compare(day, to: $0.scheduledDay, toGranularity: .day) == .orderedSame
        }
    }
    
    func deleteMeals(at indices: IndexSet, on day: Date) {
        indices
            .compactMap { meal(on: day, for: MealSlot.allCases[$0]) }
            .forEach(context.delete)
        
        do {
            try context.save()
        } catch {
            Logger.coreData.error("MealPlanView failed to delete meal: \(error.localizedDescription)")
        }
    }
    
    func day(offset: Int) -> Date {
        Date().adding(days: offset)
    }
    
    var body: some View {
        NavigationView {
            List {
                ForEach((Self.earliestDateOffset ... 7), id: \.self) { dayOffset in
                    Section(header: Text(title(for: day(offset: dayOffset)))) {
                        ForEach(MealSlot.allCases) { slot in
                            if let meal = self.meal(on: day(offset: dayOffset), for: slot) {
                                NavigationLink(destination: MealDetailView(meal: meal)) {
                                    MealRow(meal: meal)
//                                        .onDrag { NSItemProvider(object: meal.objectID.uriRepresentation().absoluteString as NSString) }
                                }
                            } else {
                                EmptyMealSlotView(slot: slot.title) {
                                    creatingMealSpace = MealSpace(day: day(offset: dayOffset), slot: slot)
                                }
//                                .onDrop(of: [.text], delegate: EmptyMealDropDelegate(context: context, targetSpace: MealSpace(day: day(offset: dayOffset), slot: slot)))
                            }
                        }
                        .onDelete { deleteMeals(at: $0, on: day(offset: dayOffset)) }
                    }
                }
            }
            .introspectTableView {
                $0.dragInteractionEnabled = true
                $0.dropDelegate = dropDelegate
                $0.dragDelegate = dragDelegate
            }
            .navigationTitle("Meal Plan")
            .listStyle(InsetGroupedListStyle())
            .sheet(item: $creatingMealSpace) { mealSpace in
                NewMealView(space: mealSpace)
            }
        }
    }
}

struct MealPlanView_Previews: PreviewProvider {
    static var previews: some View {
        MealPlanView()
    }
}
