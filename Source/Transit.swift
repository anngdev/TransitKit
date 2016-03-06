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

class Transit: NSObject {
    
    var direction: Direction
    var line: Line
    var train: Train
    
    init(line: Line, train: Train, direction: Direction) {
        self.line = line
        self.train = train
        self.direction = direction
    }
}

extension Transit: UIViewControllerTransitioningDelegate {
    
    func animationControllerForPresentedController(
        presented: UIViewController,
        presentingController presenting: UIViewController,
        sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning?
    {
        direction = .Go
        return self
    }
    
    func animationControllerForDismissedController(dismissed: UIViewController)
        -> UIViewControllerAnimatedTransitioning?
    {
        direction = .Return
        return self
    }
}

extension Transit: UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return line.duration()
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        let container = transitionContext.containerView()!
        let fromView = transitionContext.viewForKey(UITransitionContextFromViewKey)!
        let toView = transitionContext.viewForKey(UITransitionContextToViewKey)!
        
        let toVC = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
        toView.frame = transitionContext.finalFrameForViewController(toVC)
        container.addSubview(toView)
        
        if direction == .Return {
            // fromView should be start at most top position
            container.bringSubviewToFront(fromView)
        }
        
        if let animateLine = line as? AnimationLine {
            animateLine.animate(fromView, toView: toView, inView: container, direction: direction)
            
            // passengers
            if let station = toVC as? StationPassenger {
                for passenger in train.passengers {
                    let toPassenger = station.passengerByName(passenger.name)
                    
                    guard let p = toPassenger else { continue }
                    
                    let currentView = passenger.view
                    let targetView = p.view
                    let animateView = currentView.snapshotViewAfterScreenUpdates(false)
                    let currentFrame = currentView.superview!.convertRect(currentView.frame, toView: fromView)
                    let targetFrame = targetView.superview!.convertRect(targetView.frame, toView: toView)
                    
                    animateView.frame = currentFrame
                    container.addSubview(animateView)
                    
                    currentView.hidden = true
                    targetView.hidden = true
                    animateLine.animatePassenger(animateView, targetFrame: targetFrame, direction: direction)
                    after(line.duration()) {
                        currentView.hidden = false
                        targetView.hidden = false
                    }
                }
            }
        }
        
        if line is AnimationLine {
            after(line.duration()) {
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
            }
        }
    }
}

// MARK:- Util

func after(delay: Double, run:() -> ()) {
    dispatch_after(
        dispatch_time(DISPATCH_TIME_NOW, Int64(delay * Double(NSEC_PER_SEC))),
        dispatch_get_main_queue(), run)
}