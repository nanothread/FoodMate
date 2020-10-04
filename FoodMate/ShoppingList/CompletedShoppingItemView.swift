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
    var uncompleteItem: () -> Void
    
    var body: some View {
        VStack {
            HStack {
                Button(action: uncompleteItem) {
                        Image(systemName: "checkmark.square")
                            .foregroundColor(Color(.systemGray))
                }
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
