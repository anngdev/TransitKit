//
//  Line.swift
//  Transit
//
//  Created by Amornchai Kanokpullwad on 3/5/2559 BE.
//  Copyright © 2559 zoonref. All rights reserved.
//

import UIKit

enum Direction {
    case Go, Return
}

public class Transit: UIPercentDrivenInteractiveTransition {
    
    var direction: Direction
    var line: Line
    var train: Train
    
    private var tempContext: UIViewControllerContextTransitioning?
    
    private var displayLink: CADisplayLink?
    private var displayLinkLastTime: NSTimeInterval = 0
    
    init(line: Line, train: Train, direction: Direction) {
        self.line = line
        self.train = train
        self.direction = direction
    }
}

extension Transit: UIViewControllerTransitioningDelegate {
    
    public func animationControllerForPresentedController(
        presented: UIViewController,
        presentingController presenting: UIViewController,
        sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning?
    {
        return self
    }
    
    public func animationControllerForDismissedController(dismissed: UIViewController)
        -> UIViewControllerAnimatedTransitioning?
    {
        return self
    }
    
    public func interactionControllerForPresentation(animator: UIViewControllerAnimatedTransitioning)
        -> UIViewControllerInteractiveTransitioning?
    {
        return line is InteractionLine ? self : nil
    }
    
    public func interactionControllerForDismissal(animator: UIViewControllerAnimatedTransitioning)
        -> UIViewControllerInteractiveTransitioning?
    {
        return line is InteractionLine ? self : nil
    }
}

extension Transit: UIViewControllerAnimatedTransitioning {
    
    public func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return line.duration()
    }
    
    public func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        let co = ContextObjects(context: transitionContext)
        
        co.toView.frame = transitionContext.finalFrameForViewController(co.toVC)
        co.container.addSubview(co.toView)
        
        if direction == .Return {
            // fromView should be start at most top position
            co.container.bringSubviewToFront(co.fromView)
        }
        
        // normal animation
        if let animateLine = line as? AnimationLine {
            animate(animateLine, direction: direction, toStation: co.toVC,
                fromView: co.fromView, toView: co.toView, inView: co.container, context: transitionContext)
        }
        
        // display link animation
        if let progressLine = line as? ProgressLine {
            progress(progressLine, direction: direction, toStation: co.toVC,
                fromView: co.fromView, toView: co.toView, inView: co.container, context: transitionContext)
        }
    }
    
}

extension Transit { // : UIPercentDrivenInteractiveTransition
    
    public override func startInteractiveTransition(transitionContext: UIViewControllerContextTransitioning) {
        tempContext = transitionContext
        
    }
    
    public override func updateInteractiveTransition(percentComplete: CGFloat) {
        if let context = tempContext {
            let co = ContextObjects(context: context)
            // progress line
        }
        
    }
    
    public override func finishInteractiveTransition() {
        tempContext?.finishInteractiveTransition()
        endInteraction(true)
    }
    
    public override func cancelInteractiveTransition() {
        tempContext?.cancelInteractiveTransition()
        endInteraction(false)
    }
    
    private func endInteraction(finish: Bool) {
        if let context = tempContext {
            let co = ContextObjects(context: context)
            let direction = finish ? self.direction : self.direction == .Go ? .Return : .Go
            
            // pregress line
        }
        tempContext = nil
    }
}

// MARK: - Animation Line

extension Transit {
    
    func animate(line: AnimationLine, direction: Direction, toStation: Station,
        fromView: UIView, toView: UIView, inView: UIView, context: UIViewControllerContextTransitioning)
    {
        line.animate(fromView, toView: toView, inView: inView, direction: direction)
        after(line.duration()) {
            context.completeTransition(!context.transitionWasCancelled())
        }
        
        // passengers
        if let station = toStation as? StationPassenger {
            animatePassenger(train.passengers, toStation: station, byLine: line,
                fromView: fromView, toView: toView, inView: inView)
        }
    }
    
    func animatePassenger(passengers: [Passenger], toStation: StationPassenger, byLine: AnimationLine,
        fromView: UIView, toView: UIView, inView: UIView)
    {
        for passenger in passengers {
            let toPassenger = toStation.passengerByName(passenger.name)
            
            guard let p = toPassenger else { return }
            
            let currentView = passenger.view
            let targetView = p.view
            let animateView = currentView.snapshotViewAfterScreenUpdates(false)
            let currentFrame = currentView.superview!.convertRect(currentView.frame, toView: fromView)
            let targetFrame = targetView.superview!.convertRect(targetView.frame, toView: toView)
            
            animateView.frame = currentFrame
            inView.addSubview(animateView)
            
            currentView.hidden = true
            targetView.hidden = true
            
            byLine.animatePassenger(animateView, targetFrame: targetFrame, direction: direction)
            
            // show views faster to prevent glitch
            after(line.duration() - 0.01) {
                currentView.hidden = false
                targetView.hidden = false
            }
        }
    }
}

// MARK: - Progress Line

extension Transit {
    
    func progress(line: ProgressLine, direction: Direction, toStation: Station,
        fromView: UIView, toView: UIView, inView: UIView, context: UIViewControllerContextTransitioning)
    {
        tempContext = context
        let co = ContextObjects(context: context)
        performProgress(0, context: co)
        
        // setup display link
        let displayLink = CADisplayLink(target: self, selector: "progressDisplayLink:")
        displayLinkLastTime = 0
        displayLink.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: NSDefaultRunLoopMode)
        self.displayLink = displayLink
    }
    
    func progressPassenger(passengers: [Passenger], toStation: StationPassenger, byLine: ProgressLine,
        fromView: UIView, toView: UIView, inView: UIView, progress: Float)
    {
        for (index, passenger) in passengers.enumerate() {
            let toPassenger = toStation.passengerByName(passenger.name)
            
            guard let p = toPassenger else { return }
            
            let targetView = p.view
            let currentView = passenger.view
            let currentFrame = currentView.superview!.convertRect(currentView.frame, toView: fromView)
            var animateView = inView.viewWithTag(1000 + index)
            
            if animateView == nil {
                animateView = currentView.snapshotViewAfterScreenUpdates(false)
                animateView?.frame = currentFrame
                animateView?.tag = 1000 + index
                inView.addSubview(animateView!)
                
                currentView.hidden = true
                targetView.hidden = true
            }
            
            let targetFrame = targetView.superview!.convertRect(targetView.frame, toView: toView)
            byLine.progressPassenger(animateView!, fromFrame: currentFrame, toFrame: targetFrame,
                direction: direction, progress: progress)
            
            if progress == 1 {
                currentView.hidden = false
                targetView.hidden = false
                animateView?.removeFromSuperview()
            }
        }
    }
    
    private func performProgress(progress: Float, context: ContextObjects) {
        if let progressLine = line as? ProgressLine {
            progressLine.progress(context.fromView, toView: context.toView, inView: context.container,
                direction: direction, progress: progress)
            
            // passengers
            if let station = train.toStation as? StationPassenger {
                progressPassenger(train.passengers, toStation: station, byLine: progressLine,
                    fromView: context.fromView, toView: context.toView, inView: context.container, progress: progress)
            }
        }
    }
    
    func progressDisplayLink(sender: CADisplayLink) {
        let timestamp: NSTimeInterval = sender.timestamp
        if displayLinkLastTime == 0 {
            displayLinkLastTime = timestamp
        }
        
        let timeUsed = timestamp - displayLinkLastTime
        let timeRemaining = max(line.duration() - timeUsed, 0)
        if timeRemaining > 0 {
            let progress = Float(timeUsed / line.duration())
            if let context = tempContext {
                let co = ContextObjects(context: context)
                performProgress(progress, context: co)
            }
        } else {
            if let context = tempContext {
                let co = ContextObjects(context: context)
                performProgress(1, context: co)
                context.completeTransition(!context.transitionWasCancelled())
            }
            
            sender.invalidate()
            displayLink = nil
        }
    }
}

// MARK: - Interaction Line

extension Transit {
    
    public func updateInteractLine(percentComplete: Float) {
        updateInteractiveTransition(CGFloat(percentComplete))
    }
    
    public func finishInteractionLine() {
        finishInteractiveTransition()
    }
    
    public func cancelInteractionLine() {
        cancelInteractiveTransition()
    }
}

// MARK:- Util

private struct ContextObjects {
    let container: UIView
    let fromView: UIView
    let toView: UIView
    let toVC: Station
    
    init(context: UIViewControllerContextTransitioning) {
        container = context.containerView()!
        fromView = context.viewForKey(UITransitionContextFromViewKey)!
        toView = context.viewForKey(UITransitionContextToViewKey)!
        toVC = context.viewControllerForKey(UITransitionContextToViewControllerKey)!
    }
}

private func after(delay: Double, run:() -> ()) {
    dispatch_after(
        dispatch_time(DISPATCH_TIME_NOW, Int64(delay * Double(NSEC_PER_SEC))),
        dispatch_get_main_queue(), run)
}