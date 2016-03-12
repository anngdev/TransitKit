//
//  SlideInZoomOutProgress.swift
//  Transit
//
//  Created by Amornchai Kanokpullwad on 3/12/2559 BE.
//  Copyright © 2559 zoonref. All rights reserved.
//

import UIKit

struct SlideInZoomOutProgress: ProgressLine {
    
    func duration() -> NSTimeInterval {
        return 0.5
    }
    
    func progress(fromView: UIView, toView: UIView, inView: UIView, direction: Direction, progress: Float) {
        if direction == .Go {
            let scale = CGFloat(1 - (0.1 * progress))
            let x = inView.frame.width - inView.frame.width * CGFloat(progress)
            fromView.transform = CGAffineTransformMakeScale(scale, scale)
            toView.frame = CGRectMake(x, 0, toView.frame.size.width, toView.frame.size.height)
            
            if progress == 1 {
                fromView.transform = CGAffineTransformIdentity
            }
        } else {
            if progress == 0 {
                toView.transform = CGAffineTransformMakeScale(0.9, 0.9)
            }
            let scale = CGFloat(0.9 + (0.1 * progress))
            let x = inView.frame.width * CGFloat(progress)
            toView.transform = CGAffineTransformMakeScale(scale, scale)
            fromView.frame = CGRectMake(x, 0, fromView.frame.size.width, fromView.frame.size.height)
        }
    }
    
    func progressPassenger(view: UIView, fromFrame: CGRect, toFrame: CGRect, direction: Direction, progress: Float) {
        func translate(progress: Float, value: CGFloat, target: CGFloat) -> CGFloat {
            return value + (target - value) * CGFloat(progress)
        }
        
        var frame = fromFrame
        frame.origin.x = translate(progress, value: frame.origin.x, target: toFrame.origin.x)
        frame.origin.y = translate(progress, value: frame.origin.y, target: toFrame.origin.y)
        frame.size.width = translate(progress, value: frame.size.width, target: toFrame.size.width)
        frame.size.height = translate(progress, value: frame.size.height, target: toFrame.size.height)
        view.frame = frame
    }
}
