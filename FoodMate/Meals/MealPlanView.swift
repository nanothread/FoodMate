//
//  MealPlanView.swift
//  FoodMate
//
//  Created by Andrew Glen on 03/10/2020.
//

import SwiftUI

// TODO: Edit the ingredients of meals
// TODO: Drag and drop to reorder the plan

struct MealPlanView: View {
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
    
    var dates: [Date] {
        (Self.earliestDateOffset ... 7).map { Date().adding(days: $0) }
    }
    
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
    
    var body: some View {
        NavigationView {
            List {
                ForEach(dates, id: \.timeIntervalSince1970) { day in
                    Section(header: Text(title(for: day))) {
                        ForEach(MealSlot.allCases) { slot in
                            if let meal = self.meal(on: day, for: slot) {
                                MealRow(name: meal.name)
                            } else {
                                EmptyMealSlotView(slot: slot.title) {
                                    creatingMealSpace = MealSpace(day: day, slot: slot)
                                }
                            }
                        }
                        .onDelete { deleteMeals(at: $0, on: day) }
                    }
                }
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
