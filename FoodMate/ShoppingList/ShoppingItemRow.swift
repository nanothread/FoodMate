//
//  ShoppingItemRow.swift
//  FoodMate
//
//  Created by Andrew Glen on 04/10/2020.
//

import SwiftUI

struct ShoppingItemRow: View {
    var name: String
    @Binding var date: Date
    @Binding var isChecked: Bool
    
    var onLocationTapped: ((Location) -> Void)?
    
    var body: some View {
        VStack {
            HStack {
                Button {
                    isChecked.toggle()
                } label: {
                    Image(systemName: isChecked ? "checkmark.square" : "square")
                        .foregroundColor(Color(.systemGray))
                }
                
                Text(name)
                Spacer()
                DatePicker("", selection: $date, displayedComponents: .date)
            }
            
            if let sortInto = onLocationTapped {
                HStack {
                    ForEach(Location.allCases) { location in
                        Button {
                            sortInto(location)
                        } label: {
                            Text(location.title)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
    }
}
