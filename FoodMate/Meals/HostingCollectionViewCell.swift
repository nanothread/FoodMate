//
//  HostingCollectionViewCell.swift
//  FoodMate
//
//  Created by Andrew Glen on 11/10/2020.
//

import UIKit
import SwiftUI

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
