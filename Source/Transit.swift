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
    
    private let viewTagOffset = 1000
    
    var line: Line
    var train: Train?
    var direction: Direction = .Go
    
    private var tempContext: ContextObjects?
    
    private var displayLink: CADisplayLink?
    private var displayLinkLastTime: NSTimeInterval = 0
    
    private var lastInteractionProgress: CGFloat = 0.0
    
    init(line: Line) {
        self.line = line
    }
}

extension Transit: UIViewControllerTransitioningDelegate {
    
    public func animationControllerForPresentedController(
        presented: UIViewController,
        presentingController presenting: UIViewController,
        sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning?
    {
        direction = .Go
        train = Train(from: source, to: presented)
        return self
    }
    
    public func animationControllerForDismissedController(dismissed: UIViewController)
        -> UIViewControllerAnimatedTransitioning?
    {
        direction = .Return
        train = Train(from: dismissed, to: dismissed.presentingViewController!)
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

extension Transit: UINavigationControllerDelegate {
    
    public func navigationController(navigationController: UINavigationController,
        animationControllerForOperation operation: UINavigationControllerOperation,
        fromViewController fromVC: UIViewController,
        toViewController toVC: UIViewController) -> UIViewControllerAnimatedTransitioning?
    {
        direction = operation == .Pop ? .Return : .Go
        train = Train(from: fromVC, to: toVC)
        return operation == .None ? nil : self
    }
    
    public func navigationController(navigationController: UINavigationController,
        interactionControllerForAnimationController animationController: UIViewControllerAnimatedTransitioning)
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
        co.container.layoutIfNeeded()
        
        if direction == .Return {
            // fromView should be start at most top position
            co.container.bringSubviewToFront(co.fromView)
        }
        
        line.beforeDepart(co.fromView, toView: co.toView, inView: co.container, direction: direction)
        
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

// MARK: - Animation Line

extension Transit {
    
    func animate(line: AnimationLine, direction: Direction, toStation: Station,
        fromView: UIView, toView: UIView, inView: UIView, context: UIViewControllerContextTransitioning)
    {
        // passengers
        if let station = toStation as? StationPassenger {
            animatePassenger(train!.passengers, toStation: station, byLine: line,
                fromView: fromView, toView: toView, inView: inView)
        }
        
        line.animate(fromView, toView: toView, inView: inView, direction: direction)
        
        after(line.duration() + 0.05) {
            line.afterArrived(fromView, toView: toView, inView: inView, direction: direction)
            context.completeTransition(!context.transitionWasCancelled())
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
            let animateView = currentView.copyView()
            let currentFrame = currentView.superview!.convertRect(currentView.frame, toView: nil)
            let targetFrame = targetView.superview!.convertRect(targetView.frame, toView: nil)
            
            animateView.removeConstraints(animateView.constraints)
            animateView.translatesAutoresizingMaskIntoConstraints = true
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
            
            after(line.duration()) {
                animateView.removeFromSuperview()
            }
        }
    }
}

// MARK: - Progress Line

extension Transit {
    
    func progress(line: ProgressLine, direction: Direction, toStation: Station,
        fromView: UIView, toView: UIView, inView: UIView, context: UIViewControllerContextTransitioning)
    {
        tempContext = ContextObjects(context: context)
        if let co = tempContext {
            performProgress(0, context: co)
            
            // setup display link
            let displayLink = CADisplayLink(target: self, selector: #selector(Transit.progressDisplayLink(_:)))
            displayLinkLastTime = 0
            displayLink.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: NSRunLoopCommonModes)
            self.displayLink = displayLink
        }
    }
    
    private func performProgress(progress: CGFloat, context: ContextObjects) {
        if let progressLine = line as? ProgressLine {
            progressLine.progress(context.fromView, toView: context.toView, inView: context.container,
                direction: direction, progress: progress)
            
            // passengers
            if let station = train!.toStation as? StationPassenger {
                moveAllPassengers(train!.passengers, toStation: station, byLine: progressLine,
                    context: context, progress: progress)
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
            let progress = CGFloat(timeUsed / line.duration())
            if let co = tempContext {
                performProgress(progress, context: co)
            }
        } else {
            sender.invalidate()
            displayLink = nil
            
            if let co = tempContext {
                performProgress(1, context: co)
                line.afterArrived(co.fromView, toView: co.toView, inView: co.container, direction: direction)
                
                after(0.05) {
                    co.context.completeTransition(!co.context.transitionWasCancelled())
                }
            }
        }
    }
}

// MARK: - Interaction Line

extension Transit {
    
    public func updateInteractLine(percentComplete: CGFloat) {
        lastInteractionProgress = percentComplete
        if let co = tempContext {
            if let interactionLine = line as? InteractionLine {
                interactionLine.progress(co.fromView, toView: co.toView, inView: co.container, direction: direction,
                    progress: percentComplete)
                
                if let station = train!.toStation as? StationPassenger {
                    moveAllPassengers(train!.passengers, toStation: station, byLine: interactionLine,
                        context: co, progress: percentComplete)
                }
            }
        }
    }
    
    public func finishInteractionLine(withVelocity v: CGPoint? = nil) {
        finishInteractiveTransition()
        endInteraction(true, withVelocity: v)
    }
    
    public func cancelInteractionLine(withVelocity v: CGPoint? = nil) {
        cancelInteractiveTransition()
        endInteraction(false, withVelocity: v)
    }
    
    private func endInteraction(finish: Bool, withVelocity: CGPoint?) {
        guard let co = tempContext else { return }
        guard let interactionLine = line as? InteractionLine else { return }
        
        var duration: NSTimeInterval = 0
        if finish {
            duration = interactionLine.interactFinish(co.fromView, toView: co.toView, inView: co.container,
                direction: direction, lastProgress: lastInteractionProgress, velocity: withVelocity)
        } else {
            duration = interactionLine.interactCancel(co.fromView, toView: co.toView, inView: co.container,
                direction: direction, lastProgress: lastInteractionProgress, velocity: withVelocity)
        }
        
        if let station = train!.toStation as? StationPassenger {
            finishMoveAllPassengers(train!.passengers, toStation: station, byLine: interactionLine,
                context: co, duration: duration, finish: finish)
        }
        
        after(duration) {
            interactionLine.afterArrived(co.fromView, toView: co.toView,
                inView: co.container, direction: self.direction)
            co.context.completeTransition(finish)
        }
    }
}

// MARK: - Passengers

extension Transit {
    
    // for progress and interactive
    private func moveAllPassengers(passengers: [Passenger], toStation: StationPassenger, byLine: Line,
        context: ContextObjects, progress: CGFloat)
    {
        guard byLine is ProgressLine else { return }
        
        for (index, passenger) in passengers.enumerate() {
            let toPassenger = toStation.passengerByName(passenger.name)
            
            guard let p = toPassenger else { return }
            
            let targetView = p.view
            let currentView = passenger.view
            var animateView = context.container.viewWithTag(viewTagOffset + index)
            
            let currentFrame = currentView.superview!.convertRect(currentView.frame, toView: context.fromView)
            let startFrame = CGRectOffset(currentFrame, 0, context.fromOffset)
            
            if animateView == nil {
                animateView = currentView.copyView()
                animateView?.removeConstraints(animateView!.constraints)
                animateView?.translatesAutoresizingMaskIntoConstraints = true
                animateView?.frame = startFrame
                animateView?.tag = viewTagOffset + index
                context.container.addSubview(animateView!)
                
                currentView.hidden = true
                targetView.hidden = true
            }
            
            let targetFrame = targetView.superview!.convertRect(targetView.frame, toView: context.toView)
            let endFrame = CGRectOffset(targetFrame, 0, context.toOffset)
                        
            if let l = byLine as? ProgressLine {
                l.progressPassenger(animateView!, fromFrame: startFrame, toFrame: endFrame, direction: direction,
                    progress: progress)
                
                if progress == 1 {
                    currentView.hidden = false
                    targetView.hidden = false
                    animateView?.removeFromSuperview()
                }
            }
        }
    }
    
    private func finishMoveAllPassengers(passengers: [Passenger], toStation: StationPassenger, byLine: InteractionLine,
        context: ContextObjects, duration: NSTimeInterval, finish: Bool)
    {
        for (index, passenger) in passengers.enumerate() {
            let toPassenger = toStation.passengerByName(passenger.name)
            
            guard let p = toPassenger else { return }
            guard let animateView = context.container.viewWithTag(viewTagOffset + index) else { continue }
            
            let currentView = passenger.view
            let targetView = p.view
            
            let currentFrame = currentView.superview!.convertRect(currentView.frame, toView: context.fromView)
            let startFrame = CGRectOffset(currentFrame, 0, context.fromOffset)
            
            let targetFrame = targetView.superview!.convertRect(targetView.frame, toView: context.toView)
            let endFrame = CGRectOffset(targetFrame, 0, context.toOffset)
            
            if finish {
                byLine.interactPassengerFinish(animateView, toFrame: endFrame, duration: duration)
            } else {
                byLine.interactPassengerCancel(animateView, toFrame: startFrame, duration: duration)
            }
            
            after(duration) {
                currentView.hidden = false
                targetView.hidden = false
                animateView.removeFromSuperview()
            }
        }
    }
}

// MARK: - UIPercentDrivenInteractiveTransition

extension Transit {
    
    public override func startInteractiveTransition(transitionContext: UIViewControllerContextTransitioning) {
        // add view first
        let co = ContextObjects(context: transitionContext)
        co.toView.frame = transitionContext.finalFrameForViewController(co.toVC)
        co.container.addSubview(co.toView)
        if direction == .Return {
            // fromView should be start at most top position
            co.container.bringSubviewToFront(co.fromView)
        }
        
        // then save the updated context
        tempContext = ContextObjects(context: transitionContext)
        if let co = tempContext {
            line.beforeDepart(co.fromView, toView: co.toView, inView: co.container, direction: direction)
        }
    }
}

// MARK:- Util

private struct ContextObjects {
    let context: UIViewControllerContextTransitioning
    let container: UIView
    let fromView: UIView
    let toView: UIView
    let fromVC: Station
    let toVC: Station
    let fromOffset: CGFloat
    let toOffset: CGFloat
    
    init(context: UIViewControllerContextTransitioning) {
        self.context = context
        container = context.containerView()!
        fromView = context.viewForKey(UITransitionContextFromViewKey)!
        toView = context.viewForKey(UITransitionContextToViewKey)!
        fromVC = context.viewControllerForKey(UITransitionContextFromViewControllerKey)!
        toVC = context.viewControllerForKey(UITransitionContextToViewControllerKey)!
        fromOffset = fromVC.topLayoutGuide.length
        toOffset = toVC.topLayoutGuide.length
    }
}

private func after(delay: Double, run:() -> ()) {
    dispatch_after(
        dispatch_time(DISPATCH_TIME_NOW, Int64(delay * Double(NSEC_PER_SEC))),
        dispatch_get_main_queue(), run)
}

private extension UIView {
    func copyView() -> UIView {
        if let s = self as? UIImageView {
            s.highlighted = false
        }
        return NSKeyedUnarchiver.unarchiveObjectWithData(NSKeyedArchiver.archivedDataWithRootObject(self)) as! UIView
    }
}