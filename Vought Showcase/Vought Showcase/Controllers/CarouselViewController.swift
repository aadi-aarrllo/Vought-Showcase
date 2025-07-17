//
//  CarouselViewController.swift
//  Vought Showcase
//
//  Created by Burhanuddin Rampurawala on 06/08/24.
//

import Foundation
import UIKit


final class CarouselViewController: UIViewController {
    
    /// Container view for the carousel
    @IBOutlet private weak var containerView: UIView!
    
    /// Carousel control with page indicator
//    @IBOutlet private weak var carouselControl: UIPageControl!
    
    /// Segmented progress bar at the top
    @IBOutlet weak var segmentedProgressBar: SegmentedProgressBar!
    
    /// Page view controller for carousel
    private var pageViewController: UIPageViewController?
    
    /// Carousel items
    private var items: [CarouselItem] = []
    
    /// Cached view controllers for items
    private var controllers: [UIViewController] = []
    
    /// Current item index
    private var currentItemIndex: Int = 0 {
        didSet {
//            // Update carousel control page
//            self.carouselControl.currentPage = currentItemIndex
        }
    }
    
    /// Flag to prevent concurrent transitions
    private var isTransitioning: Bool = false

    /// Tap gesture recognizer for navigation
    private var tapGesture: UITapGestureRecognizer?

    /// Initializer
    /// - Parameter items: Carousel items
    public init(items: [CarouselItem]) {
        self.items = items
        super.init(nibName: "CarouselViewController", bundle: nil)
    }
    
    
    required init?(coder: NSCoder) {
        self.items = []
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initPageViewController()
//        initCarouselControl()
        initSegmentedProgressBar()
        setNeedsStatusBarAppearanceUpdate()
    }
    
    
    /// Initialize page view controller
    private func initPageViewController() {
        
        // Create pageViewController
        pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal,
                                                  options: nil)
        
        // Set up pageViewController
        guard !items.isEmpty else { return }
        controllers = items.map { $0.getController() }
        pageViewController?.setViewControllers([controllers[currentItemIndex]], direction: .forward, animated: false)
        
        guard let theController = pageViewController else { return }
        add(asChildViewController: theController, containerView: containerView)
        
        
        //        pageViewController?.dataSource = self
        //        pageViewController?.delegate = self
        pageViewController?.dataSource = nil
        pageViewController?.delegate = nil
        
//        pageViewController?.setViewControllers(
//            [getController(at: currentItemIndex)], direction: .forward, animated: true)
//
//        guard let theController = pageViewController else {
//            return
//        }
//
//        // Add pageViewController in container view
//        add(asChildViewController: theController,
//            containerView: containerView)
//    }
        
        pageViewController?.view.gestureRecognizers = []

        tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        if let tapGesture = tapGesture {
            containerView.addGestureRecognizer(tapGesture)
        }
    }

    /// Handle tap gesture to navigate to next or previous image
    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        guard !controllers.isEmpty, !isTransitioning else { return }

        isTransitioning = true
        tapGesture?.isEnabled = false
        segmentedProgressBar.isPaused = true

        let tapLocation = gesture.location(in: containerView)
        let isForwardTap = tapLocation.x >= containerView.bounds.width / 2
        let newIndex = isForwardTap ? (currentItemIndex + 1) % controllers.count : (currentItemIndex - 1 + controllers.count) % controllers.count

        let direction: UIPageViewController.NavigationDirection = isForwardTap ? .forward : .reverse

        let newController = controllers[newIndex]
        pageViewController?.setViewControllers([newController], direction: direction, animated: false) { _ in
            self.currentItemIndex = newIndex
            self.segmentedProgressBar.setSegment(to: newIndex, silent: true)
            self.segmentedProgressBar.isPaused = false
            self.segmentedProgressBar.startAnimation()
            self.resetInteractionState()
        }
    }

    private func resetInteractionState() {
        isTransitioning = false
        tapGesture?.isEnabled = true
    }

    /// Initialize segmented progress bar
    private func initSegmentedProgressBar() {
        guard !items.isEmpty else { return }
        segmentedProgressBar.configure(numberOfSegments: items.count)
        segmentedProgressBar.delegate = self
        segmentedProgressBar.topColor = .white
        segmentedProgressBar.bottomColor = .gray.withAlphaComponent(0.25)
        segmentedProgressBar.startAnimation()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

extension CarouselViewController: SegmentedProgressBarDelegate {
    func segmentedProgressBarChangedIndex(index: Int) {
        guard !isTransitioning, index < controllers.count else { return }
        let direction: UIPageViewController.NavigationDirection = index > currentItemIndex ? .forward : .reverse
        isTransitioning = true
        tapGesture?.isEnabled = false

        pageViewController?.setViewControllers([controllers[index]], direction: direction, animated: false) { _ in
            self.currentItemIndex = index
            self.segmentedProgressBar.setSegment(to: index, silent: true)
            self.segmentedProgressBar.isPaused = false
            self.segmentedProgressBar.startAnimation()
            self.resetInteractionState()
        }
    }

    func segmentedProgressBarFinished() {
        self.segmentedProgressBar.rewind(silent: true)
        self.segmentedProgressBar.startAnimation()
    }
}
