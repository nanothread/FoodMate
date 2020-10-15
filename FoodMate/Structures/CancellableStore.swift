//
//  CancellableStore.swift
//  FoodMate
//
//  Created by Andrew Glen on 07/10/2020.
//

import Foundation
import Combine

/// An object containing a set of cancellables. It makes setting up publisher chains in `View`s easier.
class CancellableStore: ObservableObject {
    var cancellables = Set<AnyCancellable>()
}
