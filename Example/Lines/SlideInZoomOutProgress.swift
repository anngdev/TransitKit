//
//  SlideInZoomOutProgress.swift
//  Transit
//
//  Created by Amornchai Kanokpullwad on 3/12/2559 BE.
//  Copyright © 2559 zoonref. All rights reserved.
//

import UIKit
import Transit

struct SlideInZoomOutProgress: ProgressLine {
    
    func duration() -> NSTimeInterval {
        return 0.5
    }
    
    func beforeDepart(fromView: UIView, toView: UIView, inView: UIView, direction: Direction) {
        if direction == .Return {
            toView.transform = CGAffineTransformMakeScale(0.9, 0.9)
        }
    }
    
    func afterArrived(fromView: UIView, toView: UIView, inView: UIView, direction: Direction) {
        if direction == .Go {
            fromView.transform = CGAffineTransformIdentity
        }
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
}
