//
//  CollectionViewManager.swift
//  FoodMate
//
//  Created by Andrew Glen on 11/10/2020.
//

import UIKit

class CollectionViewManager: NSObject, ObservableObject {
    typealias CellRegistration = UICollectionView.CellRegistration<HostingCollectionViewCell, MealSlotModel>

    var sections = [DayOffset]()
    private var model: MealPlanModel!

    private(set) var collectionViewController: UICollectionViewController!
    
    var selectMeal: ((Meal) -> Void)?
    
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
    
    func configure(meals: Set<Meal>, cellRegistration: CellRegistration, deleteMeal: @escaping (Meal) -> Bool, saveChanges: @escaping () -> Void) {
        collectionViewController = makeCollectionViewController(deleteMeal: deleteMeal)
        let collectionView = collectionViewController.collectionView!
        
        model = MealPlanModel(dayOffsets: sections, saveMealChanges: saveChanges, reloadCollectionView: collectionView.reloadData)
        
        // Set up data source
        let dataSource = MealPlanModel.DataSource(
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
        collectionView.delegate = self
        collectionView.dragInteractionEnabled = true
        collectionView.dragDelegate = model
        collectionView.dropDelegate = model
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

extension CollectionViewManager: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard case .filled(let meal) = model.cellModel(at: indexPath) else { return }
        selectMeal?(meal)
    }
}
