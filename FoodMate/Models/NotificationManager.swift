//
//  NotificationManager.swift
//  FoodMate
//
//  Created by Andrew Glen on 06/10/2020.
//

import Foundation
import UserNotifications
import Combine
import CoreData

class NotificationManager: ObservableObject {
    enum Error: Swift.Error {
        case permissionDenied
        case permissionRequestFailed(Swift.Error)
        case schedulingFailed(Swift.Error)
    }

    // TODO: the managed object should be saved persistently before calling this method
    // so the objectID is set in stone.
    func considerSettingNotification(for meal: Meal) -> Future<Void, Error>? {
        let frozenIngredients = meal.ingredients.flatMap(\.children).filter { $0.location == .freezer }
        
        guard !frozenIngredients.isEmpty else {
            return nil
        }
        
        return Future { promise in
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge]) { granted, error in
                if let error = error {
                    promise(.failure(.permissionRequestFailed(error)))
                }
                else if !granted {
                    promise(.failure(.permissionDenied))
                }
                else {
                    let ingredients = ListFormatter.localizedString(byJoining: frozenIngredients.map(\.name))
                    
                    let content = UNMutableNotificationContent()
                    content.title = "Defrost \(ingredients)"
                    
                    var components = DateComponents()
                    components.day = Calendar.current.component(.day, from: meal.scheduledDay)
                    components.hour = 11

                    let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
                    let notificationID = meal.objectID.uriRepresentation().absoluteString
                    let request = UNNotificationRequest(identifier: notificationID, content: content, trigger: trigger)
                    
                    UNUserNotificationCenter.current().add(request) { error in
                        if let error = error {
                            promise(.failure(.schedulingFailed(error)))
                        } else {
                            promise(.success(()))
                        }
                        
                    }
                }
            }
        }
    }
}
