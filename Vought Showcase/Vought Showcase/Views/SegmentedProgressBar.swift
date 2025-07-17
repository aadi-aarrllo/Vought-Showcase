//
//  SegmentedProgressBar.swift
//  Vought Showcase
//
//  Created by Burhanuddin Rampurawala on 07/08/24.
//

import Foundation
import UIKit

/// A delegate protocol for handling SegmentedProgressBar events.
protocol SegmentedProgressBarDelegate: AnyObject {
    /// Called when the progress bar changes to a new segment.
    /// - Parameter index: The index of the new active segment.
    func segmentedProgressBarChangedIndex(index: Int)
    
    /// Called when the progress bar finishes animating all segments.
    func segmentedProgressBarFinished()
}

/// A custom UIView subclass that displays a segmented progress bar with animated filling.
class SegmentedProgressBar: UIView {
    
    /// The delegate to receive progress bar events.
    weak var delegate: SegmentedProgressBarDelegate?
    
    /// The color of the filled portion of each segment.
    var topColor = UIColor.white {
        didSet {
            self.updateColors()
        }
    }
    
    /// The color of the unfilled portion of each segment.
    var bottomColor = UIColor.gray.withAlphaComponent(0.25) {
        didSet {
            self.updateColors()
        }
    }
    
    /// The padding between segments.
    var padding: CGFloat = 4.0
    
    /// A boolean indicating whether the progress bar animation is paused.
    var isPaused: Bool = false {
        didSet {
            if isPaused {
                for segment in segments {
                    let layer = segment.topSegmentView.layer
                    let pausedTime = layer.convertTime(CACurrentMediaTime(), from: nil)
                    layer.speed = 0.0
                    layer.timeOffset = pausedTime
                }
            } else {
                let segment = segments[currentAnimationIndex]
                let layer = segment.topSegmentView.layer
                let pausedTime = layer.timeOffset
                layer.speed = 1.0
                layer.timeOffset = 0.0
                layer.beginTime = 0.0
                let timeSincePause = layer.convertTime(CACurrentMediaTime(), from: nil) - pausedTime
                layer.beginTime = timeSincePause
            }
        }
    }
    
    private var segments = [Segment]()
    private let duration: TimeInterval
    private var hasDoneLayout = false
    private var currentAnimationIndex = 0
    
    /// Initializes a new SegmentedProgressBar with the specified number of segments and duration.
    /// - Parameters:
    ///   - numberOfSegments: The number of segments in the progress bar.
    ///   - duration: The duration of each segment's animation. Defaults to 5.0 seconds.
    init(numberOfSegments: Int, duration: TimeInterval = 5.0) {
        self.duration = duration
        super.init(frame: CGRect.zero)
        
        for _ in 0..<numberOfSegments {
            let segment = Segment()
            addSubview(segment.bottomSegmentView)
            addSubview(segment.topSegmentView)
            segments.append(segment)
        }
        self.updateColors()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if hasDoneLayout {
            return
        }
        let width = (frame.width - (padding * CGFloat(segments.count - 1)) ) / CGFloat(segments.count)
        for (index, segment) in segments.enumerated() {
            let segFrame = CGRect(x: CGFloat(index) * (width + padding), y: 0, width: width, height: frame.height)
            segment.bottomSegmentView.frame = segFrame
            segment.topSegmentView.frame = segFrame
            segment.topSegmentView.frame.size.width = 0
            
            let cr = frame.height / 2
            segment.bottomSegmentView.layer.cornerRadius = cr
            segment.topSegmentView.layer.cornerRadius = cr
        }
        hasDoneLayout = true
    }
    
    /// Starts the progress bar animation.
    func startAnimation() {
        layoutSubviews()
        animate()
    }
    
    private func animate(animationIndex: Int = 0) {
        let nextSegment = segments[animationIndex]
        currentAnimationIndex = animationIndex
        self.isPaused = false
        UIView.animate(withDuration: duration, delay: 0.0, options: .curveLinear, animations: {
            nextSegment.topSegmentView.frame.size.width = nextSegment.bottomSegmentView.frame.width
        }) { (finished) in
            if !finished {
                return
            }
            self.next()
        }
    }
    
    private func updateColors() {
        for segment in segments {
            segment.topSegmentView.backgroundColor = topColor
            segment.bottomSegmentView.backgroundColor = bottomColor
        }
    }
    
    private func next() {
        let newIndex = self.currentAnimationIndex + 1
        if newIndex < self.segments.count {
            self.animate(animationIndex: newIndex)
            self.delegate?.segmentedProgressBarChangedIndex(index: newIndex)
        } else {
            self.delegate?.segmentedProgressBarFinished()
        }
    }
    
    /// Skips the current segment and moves to the next one.
    func skip() {
        let currentSegment = segments[currentAnimationIndex]
        currentSegment.topSegmentView.frame.size.width = currentSegment.bottomSegmentView.frame.width
        currentSegment.topSegmentView.layer.removeAllAnimations()
        self.next()
    }
    
    /// Rewinds to the previous segment.
    func rewind() {
        let currentSegment = segments[currentAnimationIndex]
        currentSegment.topSegmentView.layer.removeAllAnimations()
        currentSegment.topSegmentView.frame.size.width = 0
        let newIndex = max(currentAnimationIndex - 1, 0)
        let prevSegment = segments[newIndex]
        prevSegment.topSegmentView.frame.size.width = 0
        self.animate(animationIndex: newIndex)
        self.delegate?.segmentedProgressBarChangedIndex(index: newIndex)
    }
}

/// A private class representing a single segment of the progress bar.
fileprivate class Segment {
    /// The view representing the unfilled portion of the segment.
    let bottomSegmentView = UIView()
    /// The view representing the filled portion of the segment.
    let topSegmentView = UIView()
    init() {
    }
}
