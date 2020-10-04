//
//  ActiveShoppingItemView.swift
//  FoodMate
//
//  Created by Andrew Glen on 03/10/2020.
//

import SwiftUI

struct ActiveShoppingItemView: View {
    var name: String
    @Binding var date: Date
    
    var body: some View {
        HStack {
            Image(systemName: "square")
                .foregroundColor(Color(.systemGray))
            Text(name)
            Spacer()
            DatePicker("", selection: $date, displayedComponents: .date)
        }
    }
}

struct ActiveShoppingItemView_Previews: PreviewProvider {
    static var previews: some View {
        ActiveShoppingItemView(name: "Parmesan", date: Binding(get: { Date() }, set: { _ in }))
    }
}
