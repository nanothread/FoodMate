//
//  FoodMateApp.swift
//  FoodMate
//
//  Created by Andrew Glen on 03/10/2020.
//

import SwiftUI

@main
struct FoodMateApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContainerView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
