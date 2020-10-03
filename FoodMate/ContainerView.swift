//
//  ContainerView.swift
//  FoodMate
//
//  Created by Andrew Glen on 03/10/2020.
//

import SwiftUI

struct ContainerView: View {
    var body: some View {
        TabView {
            IngredientsView()
                .tabItem {
                    Image(systemName: "cube.box")
                    Text("Ingredients")
                }
            
            MealPlanView()
                .tabItem {
                    Image(systemName: "calendar")
                    Text("Meals")
                }
            
            ShoppingListView()
                .tabItem {
                    Image(systemName: "list.bullet")
                    Text("Shopping")
                }
        }
    }
}

struct ContainerView_Previews: PreviewProvider {
    static var previews: some View {
        ContainerView()
    }
}
