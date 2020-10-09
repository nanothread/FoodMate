//
//  Logging.swift
//  FoodMate
//
//  Created by Andrew Glen on 03/10/2020.
//

import Foundation
import os

// Exposes `Logger` to the result of the module without having to `import os` in every file
enum Logger {
    private static let subsystem = Bundle.main.bundleIdentifier!
    static let coreData = os.Logger(subsystem: subsystem, category: "coreData")
    static let notifications = os.Logger(subsystem: subsystem, category: "notifications")
    static let dragDrop = os.Logger(subsystem: subsystem, category: "dragDrop")
}
