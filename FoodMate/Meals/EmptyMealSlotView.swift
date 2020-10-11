//
//  EmptyMealSlotView.swift
//  FoodMate
//
//  Created by Andrew Glen on 03/10/2020.
//

import SwiftUI

struct EmptyMealSlotView: View {
    var slot: String
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Label("Add \(slot)", systemImage: "plus")
        }
        .frame(maxWidth: .infinity, minHeight: 44)
        .background(Color(.secondarySystemGroupedBackground))
    }
}

struct EmptyMealSlotView_Previews: PreviewProvider {
    static var previews: some View {
        EmptyMealSlotView(slot: "Lunch") { }
    }
}
