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
    lazy var collectionView: UICollectionView = {
        let config = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        let layout = UICollectionViewCompositionalLayout.list(using: config)
        return UICollectionView(frame: .zero, collectionViewLayout: layout)
    }()
    
    lazy var dataSource: UICollectionViewDiffableDataSource = {
        UICollectionViewDiffableDataSource<Date, Meal>(
            collectionView: collectionView,
            cellProvider: { collectionView, indexPath, meal in
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! MealPlanCell
                cell.configure(withMeal: meal)
                return cell
            }
        )
    }()
}

struct MealPlanView: View {
    var body: some View {
        NavigationView {
            MealPlanListView()
                .navigationTitle("Meal Plan")
        }
    }
}

struct MealPlanListView: UIViewRepresentable {
    @StateObject var viewManager = CollectionViewManager()
    @FetchRequest(entity: Meal.entity(),
                  sortDescriptors: [],
                  predicate: NSPredicate(format: "scheduledDay > %@", argumentArray: [
                    Date().adding(days: -1)
                  ]),
                  animation: nil)
    private var meals: FetchedResults<Meal>
    
    func makeUIView(context: Context) -> UICollectionView {
        let collectionView = viewManager.collectionView
        let dataSource = viewManager.dataSource
        
        collectionView.register(MealPlanCell.self, forCellWithReuseIdentifier: "cell")
        collectionView.dataSource = dataSource
        
        var snapshot = NSDiffableDataSourceSnapshot<Date, Meal>()
        let today = Date()
        snapshot.appendSections([Date().adding(days: -1), today])
        snapshot.appendItems(Array(meals), toSection: today)
        dataSource.apply(snapshot)
        
        return collectionView
    }
    
    func updateUIView(_ uiView: UICollectionView, context: Context) {
        
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
