//
//  SlideInZoomOutInteraction.swift
//  Transit
//
//  Created by Amornchai Kanokpullwad on 3/13/2559 BE.
//  Copyright © 2559 zoonref. All rights reserved.
//

import UIKit
import Transit

struct SlideInZoomOutInteraction: InteractionLine {
    
    func duration() -> NSTimeInterval {
        return 1
    }
    
    func beforeDepart(fromView: UIView, toView: UIView, inView: UIView, direction: Direction) {
        if direction == .Return {
            toView.transform = CGAffineTransformMakeScale(0.9, 0.9)
        } else {
            toView.frame = CGRectMake(inView.frame.size.width, 0, toView.frame.size.width, toView.frame.size.height)
        }
    }
    
    func afterArrived(fromView: UIView, toView: UIView, inView: UIView, direction: Direction) {
        // clear transformation
        fromView.transform = CGAffineTransformIdentity
        toView.transform = CGAffineTransformIdentity
    }
    
    func progress(fromView: UIView, toView: UIView, inView: UIView, direction: Direction, progress: CGFloat) {
        if direction == .Go {
            let scale = 1 - (0.1 * progress)
            let x = inView.frame.width - inView.frame.width * progress
            fromView.alpha = 1 - (progress * 0.5)
            fromView.transform = CGAffineTransformMakeScale(scale, scale)
            toView.frame = CGRectMake(x, 0, toView.frame.size.width, toView.frame.size.height)
        } else {
            let scale = 0.9 + (0.1 * progress)
            let x = inView.frame.width * progress
            toView.alpha = 0.5 + (progress * 0.5)
            toView.transform = CGAffineTransformMakeScale(scale, scale)
            fromView.frame = CGRectMake(x, 0, fromView.frame.size.width, fromView.frame.size.height)
        }
    }
    
    func interactFinish(fromView: UIView, toView: UIView, inView: UIView, direction: Direction,
        lastProgress: CGFloat, velocity: CGPoint?) -> NSTimeInterval
    {
        let d = NSTimeInterval(CGFloat(duration()) * (1 - lastProgress))
        UIView.animateWithDuration(d) {
            if direction == .Go {
                fromView.alpha = 0.5
                fromView.transform = CGAffineTransformMakeScale(0.9, 0.9)
                toView.frame = CGRectMake(0, 0, toView.frame.size.width, toView.frame.size.height)
            } else {
                toView.alpha = 1
                toView.transform = CGAffineTransformIdentity
                fromView.frame = CGRectMake(inView.frame.width, 0, fromView.frame.size.width, fromView.frame.size.height)
            }
        }
        return d
    }
    
    func interactCancel(fromView: UIView, toView: UIView, inView: UIView, direction: Direction,
        lastProgress: CGFloat, velocity: CGPoint?) -> NSTimeInterval
    {
        let d = NSTimeInterval(CGFloat(duration()) * abs(lastProgress))
        UIView.animateWithDuration(d) {
            if direction == .Go {
                fromView.alpha = 1
                fromView.transform = CGAffineTransformIdentity
                toView.frame = CGRectMake(inView.frame.width, 0, fromView.frame.size.width, fromView.frame.size.height)
            } else {
                toView.alpha = 0.5
                toView.transform = CGAffineTransformMakeScale(0.9, 0.9)
                fromView.frame = CGRectMake(0, 0, fromView.frame.size.width, fromView.frame.size.height)
            }
        }
        return d
    }
    
    // passenger
    
    func progressPassenger(view: UIView, fromFrame: CGRect, toFrame: CGRect, direction: Direction, progress: CGFloat) {
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