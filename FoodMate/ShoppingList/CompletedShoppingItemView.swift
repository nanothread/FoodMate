//
//  CompletedShoppingItemView.swift
//  FoodMate
//
//  Created by Andrew Glen on 04/10/2020.
//

import SwiftUI

struct CompletedShoppingItemView: View {
    var name: String
    @Binding var date: Date

    var body: some View {
        VStack {
            HStack {
                Image(systemName: "checkmark.square")
                    .foregroundColor(Color(.systemGray))
                Text(name)
                Spacer()
                DatePicker("", selection: $date, displayedComponents: .date)
            }
            
            HStack {
                ForEach(Location.allCases) { location in
                    Button {
                        
                    } label: {
                        Text(location.title)
                    }
                }
            }
            .frame(maxWidth: .infinity)
        }
    }
}

struct CompletedShoppingItemView_Previews: PreviewProvider {
    static var previews: some View {
        CompletedShoppingItemView(name: "Parmesan", date: Binding(get: { Date() }, set: { _ in }))
    }
}
