//
//  UIViewController+AddChild.swift
//  Vought Showcase
//
//  Created by Burhanuddin Rampurawala on 06/08/24.
//

import UIKit

/// Extension on UIViewController
extension UIViewController {
    
    /// Add child view controller to container view
    /// - Parameters:
    ///  - viewController: Child view controller
    ///  - containerView: Container view
    func add(asChildViewController viewController: UIViewController,
                    containerView: UIView) {
        addChild(viewController)
        containerView.addSubview(viewController.view)
        viewController.view.frame = containerView.bounds
        viewController.view.autoresizingMask = [.flexibleWidth,
                                                .flexibleHeight]
        viewController.didMove(toParent:
                                self)
    }
}
