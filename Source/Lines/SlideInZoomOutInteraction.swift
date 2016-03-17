//
//  SlideInZoomOutInteraction.swift
//  Transit
//
//  Created by Amornchai Kanokpullwad on 3/13/2559 BE.
//  Copyright © 2559 zoonref. All rights reserved.
//

import UIKit

struct SlideInZoomOutInteraction: InteractionLine {
    
    func duration() -> NSTimeInterval {
        return 1
    }
    
    func interact(fromView: UIView, toView: UIView, inView: UIView, progress: CGFloat) {
        if progress == 0 {
            toView.transform = CGAffineTransformMakeScale(0.9, 0.9)
        }
        let scale = 0.9 + (0.1 * progress)
        let x = inView.frame.width * progress
        toView.transform = CGAffineTransformMakeScale(scale, scale)
        fromView.frame = CGRectMake(x, 0, fromView.frame.size.width, fromView.frame.size.height)
    }
    
    func interactFinish(fromView: UIView, toView: UIView, inView: UIView,
        lastProgress: CGFloat, velocity: CGPoint?) -> NSTimeInterval
    {
        let d = NSTimeInterval(CGFloat(duration()) * (1 - lastProgress))
        UIView.animateWithDuration(d) {
            toView.transform = CGAffineTransformIdentity
            fromView.frame = CGRectMake(inView.frame.width, 0, fromView.frame.size.width, fromView.frame.size.height)
        }
        return d
    }
    
    func interactCancel(fromView: UIView, toView: UIView, inView: UIView,
        lastProgress: CGFloat, velocity: CGPoint?) -> NSTimeInterval
    {
        let d = NSTimeInterval(CGFloat(duration()) * lastProgress)
        UIView.animateWithDuration(d,
            animations: {
                toView.transform = CGAffineTransformMakeScale(0.9, 0.9)
                fromView.frame = CGRectMake(0, 0, fromView.frame.size.width, fromView.frame.size.height)
            },
            completion: { completion in
                // clear transformation
                toView.transform = CGAffineTransformIdentity
        })
        return d
    }
    
    // passenger
    
    func interactPassenger(view: UIView, fromFrame: CGRect, toFrame: CGRect, progress: CGFloat) {
        func translate(progress: CGFloat, value: CGFloat, target: CGFloat) -> CGFloat {
            return value + (target - value) * progress
        }
        
        var frame = fromFrame
        frame.origin.x = translate(progress, value: frame.origin.x, target: toFrame.origin.x)
        frame.origin.y = translate(progress, value: frame.origin.y, target: toFrame.origin.y)
        frame.size.width = translate(progress, value: frame.size.width, target: toFrame.size.width)
        frame.size.height = translate(progress, value: frame.size.height, target: toFrame.size.height)
        view.frame = frame
    }
    
    func interactPassengerCancel(view: UIView, toFrame: CGRect, duration: NSTimeInterval) {
        UIView.animateWithDuration(duration) {
            view.frame = toFrame
        }
    }
    
    func interactPassengerFinish(view: UIView, toFrame: CGRect, duration: NSTimeInterval) {
        UIView.animateWithDuration(duration) {
            view.frame = toFrame
        }
    }
}