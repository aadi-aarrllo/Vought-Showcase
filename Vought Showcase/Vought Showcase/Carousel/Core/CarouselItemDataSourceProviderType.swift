//
//  CarouselItemDataSourceProviderType.swift
//  Vought Showcase
//
//  Created by Burhanuddin Rampurawala on 06/08/24.
//

import Foundation

protocol CarouselItemDataSourceProviderType {
    
    /// Get carousel items
    /// - Returns: Carousel items
    func items() -> [CarouselItem]
}
