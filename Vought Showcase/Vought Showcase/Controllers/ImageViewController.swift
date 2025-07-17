//
//  ImageViewController.swift
//  Vought Showcase
//
//  Created by Burhanuddin Rampurawala on 06/08/24.
//

import UIKit

class ImageViewController: UIViewController {
    
    private let imageName: String
    private let imageView: UIImageView
    
    /// Initializer
    /// - Parameter imageName: Image name
    init(imageName: String) {
        self.imageName = imageName
        self.imageView = UIImageView()
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    /// Setup view
    private func setupView() {
        
        // Set image view properties
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: imageName)
        
        // Add image view to view
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)
        
        // Set image view constraints
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}
