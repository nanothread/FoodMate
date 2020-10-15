//
//  ActiveShoppingItemView.swift
//  FoodMate
//
//  Created by Andrew Glen on 03/10/2020.
//

import SwiftUI

/// Displays an unchecked shopping item.
struct ActiveShoppingItemView: View {
    var name: String
    @Binding var date: Date
    var completeItem: () -> Void
    
    var body: some View {
        HStack {
            Button(action: completeItem) {
                    Image(systemName: "square")
                        .foregroundColor(Color(.systemGray))
            }
            Text(name)
            Spacer()
            DatePicker("", selection: $date, displayedComponents: .date)
        }
    }
}
