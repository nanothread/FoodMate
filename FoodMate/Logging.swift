//
//  Logging.swift
//  FoodMate
//
//  Created by Andrew Glen on 03/10/2020.
//

import Foundation
import os

extension Logger {
    private static var subsystem = Bundle.main.bundleIdentifier!

    /// Logs Core Data events
    static let coreData = Logger(subsystem: subsystem, category: "coreData")
}
