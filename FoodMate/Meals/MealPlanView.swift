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
typealias DataSource = UICollectionViewDiffableDataSource<DayOffset, MealSlotType>

//struct MealPlanDay: Hashable {
//    var date: Date
//
//    init(offsetFromToday: Int) {
//        date = Date().adding(days: offsetFromToday)
//    }
//}

typealias DayOffset = Int

class MealPlanModel {
    private var cellModels = [DayOffset: [MealSlotType]]()
    var dayOffsets: [DayOffset]
    var dataSource: DataSource?
    
    init(dayOffsets: [DayOffset]) {
        self.dayOffsets = dayOffsets
    }
    
    func refresh(withMeals meals: Set<Meal>) {
        for offset in dayOffsets {
            let day = Date().adding(days: offset)
            let eligibleMeals = meals.filter { $0.scheduledDay.isInSameDay(as: day) }
            let models: [MealSlotType] = MealSlot.allCases.map { slot in
                if let meal = eligibleMeals.first(where: { $0.scheduledSlot == slot }) {
                    return .filled(meal)
                } else {
                    return .empty(MealSpace(day: day, slot: slot))
                }
            }
            
            cellModels[offset] = models
        }
        
        var snapshot = NSDiffableDataSourceSnapshot<DayOffset, MealSlotType>()
        snapshot.appendSections(dayOffsets)
        
        for offset in dayOffsets {
            guard let models = cellModels[offset] else { continue }
            snapshot.appendItems(models, toSection: offset)
        }

        dataSource?.apply(snapshot)
    }
    
    func cellModel(at indexPath: IndexPath) -> MealSlotType {
        let section = cellModels.keys.sorted()[indexPath.section]
        return cellModels[section]![indexPath.row] // TODO safe assertions
    }
}

class CollectionViewManager: ObservableObject {
    var sections = [DayOffset]()
    lazy private var model = MealPlanModel(dayOffsets: sections)

    private(set) var collectionViewController: UICollectionViewController!
    
    internal init(dayOffsets: [Int]) {
        sections = dayOffsets
    }
    
    private func makeCollectionViewController(deleteMeal: @escaping (Meal) -> Bool) -> UICollectionViewController {
        var config = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        config.headerMode = .supplementary
        config.trailingSwipeActionsConfigurationProvider = { indexPath in
            guard case .filled(let meal) = self.model.cellModel(at: indexPath) else { return nil }
            return UISwipeActionsConfiguration(actions: [
                UIContextualAction(
                    style: .destructive,
                    title: NSLocalizedString("Delete", comment: "Destroy, remove, erase."),
                    handler: { _, _, completion in
                        completion(deleteMeal(meal))
                    }
                )
            ])
        }
        
        let layout = UICollectionViewCompositionalLayout.list(using: config)
        return UICollectionViewController(collectionViewLayout: layout)
    }
    
    fileprivate func configure(meals: Set<Meal>, cellRegistration: CellRegistration, deleteMeal: @escaping (Meal) -> Bool) {
        collectionViewController = makeCollectionViewController(deleteMeal: deleteMeal)
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
            config.text = self.headerTitle(for: Date().adding(days: self.sections[indexPath.section]))
            view.contentConfiguration = config
            return view
        }
        
        collectionView.register(UICollectionViewListCell.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
        collectionView.dataSource = dataSource
        model.dataSource = dataSource
        refresh(withMeals: meals)
    }
    
    func refresh(withMeals meals: Set<Meal>) {
        model.refresh(withMeals: meals)
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
            .sheet(item: $creatingMealSpace) { mealSpace in
                NewMealView(space: mealSpace)
            }
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
    
    @Environment(\.managedObjectContext) private var context
    
    func makeUIViewController(context: Context) -> UIViewControllerType {
        viewManager.configure(
            meals: Set(meals),
            cellRegistration: CellRegistration { cell, indexPath, slotType in
                switch slotType {
                case .filled(let meal):
                    cell.host(rootView: MealRow(meal: meal))
                case .empty(let space):
                    cell.host(rootView: EmptyMealSlotView(slot: space.slot.title, action: {
                        creatingMealSpace = space
                    }))
                }
            },
            deleteMeal: deleteMeal
        )
        
        let navigationController = UINavigationController(rootViewController: viewManager.collectionViewController)
        viewManager.collectionViewController.title = "Meal Plan"
        navigationController.navigationBar.prefersLargeTitles = true
        return navigationController
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        print("Updating meal plan view!", meals.map(\.name))
        viewManager.refresh(withMeals: Set(meals))
    }
    
    func deleteMeal(_ meal: Meal) -> Bool {
        do {
            context.delete(meal)
            try context.save()
            return true
        }
        catch {
            Logger.coreData.error("MealPlanController failed to delete meal: \(error.localizedDescription)")
            return false
        }
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
