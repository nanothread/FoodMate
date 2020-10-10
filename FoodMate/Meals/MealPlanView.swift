//
//  MealPlanView.swift
//  FoodMate
//
//  Created by Andrew Glen on 10/10/2020.
//

import Foundation
import SwiftUI
import UIKit

extension UICollectionViewDiffableDataSource: ObservableObject {}
extension UICollectionView: ObservableObject {}

class CollectionViewManager: ObservableObject {
    typealias DataSource = UICollectionViewDiffableDataSource<Date, MealSlotType>
    
    var dayOffsets: [Int]
    private var dataSource: DataSource?
    
    internal init(dayOffsets: [Int]) {
        self.dayOffsets = dayOffsets
    }
    
    lazy var collectionViewController: UICollectionViewController = {
        var config = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        config.headerMode = .supplementary
        let layout = UICollectionViewCompositionalLayout.list(using: config)
        return UICollectionViewController(collectionViewLayout: layout)
    }()
    
    fileprivate func configure(meals: [Meal], cellRegistration: CellRegistration) {
        let collectionView = collectionViewController.collectionView!
        
        // Set up data source
        let dataSource = DataSource(
            collectionView: collectionViewController.collectionView,
            cellProvider: { collectionView, indexPath, meal in
                collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: meal)
            }
        )
        
        dataSource.supplementaryViewProvider = { collectionView, elementKind, indexPath in
            guard elementKind == UICollectionView.elementKindSectionHeader else { return nil }
            let view = collectionView.dequeueReusableSupplementaryView(ofKind: elementKind, withReuseIdentifier: "header", for: indexPath) as! UICollectionViewListCell
            var config = view.defaultContentConfiguration()
            config.text = self.headerTitle(for: Date().adding(days: self.dayOffsets[indexPath.section]))
            view.contentConfiguration = config
            return view
        }
        
        collectionView.register(UICollectionViewListCell.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
        collectionView.dataSource = dataSource
        self.dataSource = dataSource
        
        // Populate data source
        var snapshot = NSDiffableDataSourceSnapshot<Date, MealSlotType>()
        let sections = dayOffsets.map { Date().adding(days: $0) }
        snapshot.appendSections(sections)
        
        for section in sections {
            let eligibleMeals = meals.filter { Calendar.current.compare($0.scheduledDay, to: section, toGranularity: .day) == .orderedSame }
            let models: [MealSlotType] = MealSlot.allCases.map { slot in
                if let meal = eligibleMeals.first(where: { $0.scheduledSlot == slot }) {
                    return .filled(meal)
                } else {
                    return .empty(MealSpace(day: section, slot: slot))
                }
            }
            
            snapshot.appendItems(models, toSection: section)
        }

        dataSource.apply(snapshot)
    }
    
    private func headerTitle(for day: Date) -> String {
        let cal = Calendar.current
        if cal.isDateInYesterday(day) {
            return NSLocalizedString("Yesterday", comment: "The day before today.")
        }
        if cal.isDateInToday(day) {
            return NSLocalizedString("Today", comment: "The current day.")
        }
        if cal.isDateInTomorrow(day) {
            return NSLocalizedString("Tomorrow", comment: "The day after today.")
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE" // e.g "Satuday"
        return formatter.string(from: day)
    }
}

struct MealPlanView: View {
    @State private var creatingMealSpace: MealSpace?
    
    var body: some View {
        MealPlanController(creatingMealSpace: $creatingMealSpace)
            .edgesIgnoringSafeArea(.all)
    }
}

// Can't just be optional because we need each model instance to be identifiable
enum MealSlotModel: Hashable, Equatable {
    case filled(Meal)
    case empty(MealSpace)
}

typealias MealSlotType = MealSlotModel
fileprivate typealias CellRegistration = UICollectionView.CellRegistration<HostingCollectionViewCell, MealSlotType>

struct MealPlanController: UIViewControllerRepresentable {
    typealias UIViewControllerType = UINavigationController
    static let dayOffsets = Array(-1 ... 7)
    
    @Binding var creatingMealSpace: MealSpace?
    
    @StateObject var viewManager = CollectionViewManager(dayOffsets: Self.dayOffsets)
    @FetchRequest(entity: Meal.entity(),
                  sortDescriptors: [],
                  predicate: NSPredicate(format: "scheduledDay > %@", argumentArray: [
                    Date().adding(days: -1)
                  ]),
                  animation: nil)
    private var meals: FetchedResults<Meal>

    
    func makeUIViewController(context: Context) -> UIViewControllerType {
        viewManager.configure(
            meals: Array(meals),
            cellRegistration: CellRegistration { cell, indexPath, slotType in
                switch slotType {
                case .filled(let meal):
                    cell.host(rootView: MealRow(meal: meal))
                case .empty(let space):
                    cell.host(rootView: EmptyMealSlotView(slot: space.slot.title, action: {
                        creatingMealSpace = space
                    }))
                }
            }
        )
        
        let navigationController = UINavigationController(rootViewController: viewManager.collectionViewController)
        viewManager.collectionViewController.title = "Meal Plan"
        navigationController.navigationBar.prefersLargeTitles = true
        return navigationController
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        
    }
}

class HostingCollectionViewCell: UICollectionViewCell {
    private var hostingView: UIView?
    
    func host<Content: View>(rootView: Content) {
        hostingView?.removeFromSuperview()
        
        let hostingController = UIHostingController(rootView: rootView)
        
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(hostingController.view)
        
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: contentView.topAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            hostingController.view.heightAnchor.constraint(greaterThanOrEqualToConstant: 44)
        ])
        
        hostingView = hostingController.view
    }
}
