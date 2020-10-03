//
//  EmptyMealSlotView.swift
//  FoodMate
//
//  Created by Andrew Glen on 03/10/2020.
//

import SwiftUI

struct EmptyMealSlotView: View {
    var slot: String
    
    var body: some View {
        Label("Add \(slot)", systemImage: "plus")
    }
}

struct EmptyMealSlotView_Previews: PreviewProvider {
    static var previews: some View {
        EmptyMealSlotView(slot: "Lunch")
    }
}
