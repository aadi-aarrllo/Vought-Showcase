//
//  CarouselItem.swift
//  Vought Showcase
//
//  Created by Burhanuddin Rampurawala on 06/08/24.
//

import UIKit

/// Carousel item protocol
protocol CarouselItem {
    
    /// Get controller
    /// - Returns: UIViewController
    func getController() -> UIViewController
}
