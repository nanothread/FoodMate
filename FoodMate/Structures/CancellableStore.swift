//
//  CancellableStore.swift
//  FoodMate
//
//  Created by Andrew Glen on 07/10/2020.
//

import Foundation
import Combine

class CancellableStore: ObservableObject {
    var cancellables = Set<AnyCancellable>()
}
