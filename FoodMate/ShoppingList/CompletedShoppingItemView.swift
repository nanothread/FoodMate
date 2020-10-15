//
//  CompletedShoppingItemView.swift
//  FoodMate
//
//  Created by Andrew Glen on 04/10/2020.
//

import SwiftUI

/// Displays a checked shopping item.
struct CompletedShoppingItemView: View {
    var name: String
    @Binding var date: Date
    var uncompleteItem: () -> Void
    var sortInto: (Location) -> Void
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Button(action: uncompleteItem) {
                        Image(systemName: "checkmark.square")
                            .foregroundColor(Color(.systemGray))
                }
                
                Text(name)
                Spacer()
                DatePicker("", selection: $date, displayedComponents: .date)
            }
            
            HStack(spacing: 4) {
                ForEach(Location.allCases) { location in
                    Button {
                        sortInto(location)
                    } label: {
                        Text(location.title)
                            .foregroundColor(.white)
                            .padding(.vertical, 4)
                            .padding(.horizontal, 8)
                            .background(
                                Rectangle()
                                    .foregroundColor(.accentColor)
                                    .cornerRadius(6)
                            )
                    }
                }
            }
        }
    }
}
