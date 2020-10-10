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
    var dayOffsets: [Int]
    
    init(dayOffsets: [Int]) {
        self.dayOffsets = dayOffsets
    }
    
    lazy var collectionViewController: UICollectionViewController = {
        var config = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        config.headerMode = .supplementary
        let layout = UICollectionViewCompositionalLayout.list(using: config)
        return UICollectionViewController(collectionViewLayout: layout)
    }()
    
    lazy var dataSource: UICollectionViewDiffableDataSource<Date, MealSlotType> = {
        let dataSource = UICollectionViewDiffableDataSource<Date, MealSlotType>(
            collectionView: collectionViewController.collectionView,
            cellProvider: { collectionView, indexPath, meal in
                if case .filled(let meal) = meal  {
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "mealCell", for: indexPath) as! MealPlanCell
                    cell.configure(withMeal: meal)
                    return cell
                } else {
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "hostingCell", for: indexPath) as! HostingCollectionViewCell
                    cell.host(rootView: EmptyMealSlotView(slot: MealSlot.allCases[indexPath.row].title, action: {}))
                    return cell
                }
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
        
        return dataSource
    }()
    
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
    var body: some View {
        MealPlanController()
            .edgesIgnoringSafeArea(.all)
    }
}

// Can't just be optional because we need each model instance to be identifiable
enum MealSlotModel: Hashable, Equatable {
    case filled(Meal)
    case empty(MealSpace)
}

typealias MealSlotType = MealSlotModel

struct MealPlanController: UIViewControllerRepresentable {
    typealias UIViewControllerType = UINavigationController
    static let dayOffsets = Array(-1 ... 7)
    
    @StateObject var viewManager = CollectionViewManager(dayOffsets: Self.dayOffsets)
    @FetchRequest(entity: Meal.entity(),
                  sortDescriptors: [],
                  predicate: NSPredicate(format: "scheduledDay > %@", argumentArray: [
                    Date().adding(days: -1)
                  ]),
                  animation: nil)
    private var meals: FetchedResults<Meal>
    
    func makeUIViewController(context: Context) -> UIViewControllerType {
        let collectionView = viewManager.collectionViewController.collectionView!
        let dataSource = viewManager.dataSource
        
        collectionView.register(MealPlanCell.self, forCellWithReuseIdentifier: "mealCell")
        collectionView.register(HostingCollectionViewCell.self, forCellWithReuseIdentifier: "hostingCell")

        collectionView.register(UICollectionViewListCell.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
        collectionView.dataSource = dataSource
        
        var snapshot = NSDiffableDataSourceSnapshot<Date, MealSlotType>()
        let sections = Self.dayOffsets.map { Date().adding(days: $0) }
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
        
        
        let navigationController = UINavigationController(rootViewController: viewManager.collectionViewController)
        viewManager.collectionViewController.title = "Meal Plan"
        navigationController.navigationBar.prefersLargeTitles = true
        return navigationController
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        
    }
}

class MealPlanCell: UICollectionViewListCell {
    var hostingController: UIHostingController<MealRow>?
    
    func configure(withMeal meal: Meal) {
        hostingController?.view.removeFromSuperview()
        
        print("Configuring meal plan cell with \(meal.name)")
        let hostingController = UIHostingController(rootView: MealRow(meal: meal))
        
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(hostingController.view)
        
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: contentView.topAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            hostingController.view.heightAnchor.constraint(greaterThanOrEqualToConstant: 44)
        ])
        
        self.hostingController = hostingController
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
