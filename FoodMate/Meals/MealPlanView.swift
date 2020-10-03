//
//  MealPlanView.swift
//  FoodMate
//
//  Created by Andrew Glen on 03/10/2020.
//

import SwiftUI

struct MealPlanView: View {
    var dates: [Date] {
        (-1 ... 7).map { Date().adding(days: $0) }
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
    
    var body: some View {
        NavigationView {
            List {
                ForEach(dates, id: \.timeIntervalSince1970) { day in
                    Section(header: Text(title(for: day))) {
                        EmptyMealSlotView(slot: "Lunch")
                        EmptyMealSlotView(slot: "Dinner")
                    }
                }
            }
            .navigationTitle("Meal Plan")
            .listStyle(InsetGroupedListStyle())
        }
    }
}

struct MealPlanView_Previews: PreviewProvider {
    static var previews: some View {
        MealPlanView()
    }
}
