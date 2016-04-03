//
//  SlideInZoomOut.swift
//  Transit
//
//  Created by Amornchai Kanokpullwad on 3/5/2559 BE.
//  Copyright © 2559 zoonref. All rights reserved.
//

import UIKit
import Transit

struct SlideInZoomOutAnimation: AnimationLine {
    
    func duration() -> NSTimeInterval {
        return 0.5
    }
    
    func beforeDepart(fromView: UIView, toView: UIView, inView: UIView, direction: Direction) {}
    
    func afterArrived(fromView: UIView, toView: UIView, inView: UIView, direction: Direction) {
        if direction == .Go {
            fromView.transform = CGAffineTransformIdentity
        }
    }
    
    func animate(fromView: UIView, toView: UIView, inView: UIView, direction: Direction) {
        if direction == .Go {
            toView.frame = CGRectMake(inView.frame.width, 0, toView.frame.size.width, toView.frame.size.height)
            
            UIView.animateWithDuration(duration()) {
                fromView.transform = CGAffineTransformMakeScale(0.9, 0.9)
                fromView.alpha = 0.5
                toView.frame = CGRectMake(0, 0, toView.frame.size.width, toView.frame.size.height)
            }
        } else {
            toView.transform = CGAffineTransformMakeScale(0.9, 0.9)
            UIView.animateWithDuration(duration()) { () -> Void in
                toView.transform = CGAffineTransformIdentity
                toView.alpha = 1
                fromView.frame = CGRectMake(inView.frame.width, 0, fromView.frame.size.width, fromView.frame.size.height)
            }
        }
    }
    
    func animatePassenger(view: UIView, targetFrame: CGRect, direction: Direction) {
        UIView.animateWithDuration(duration()) {
            view.frame = targetFrame
        }
    }
}