//
//  Line.swift
//  Transit
//
//  Created by Amornchai Kanokpullwad on 3/5/2559 BE.
//  Copyright © 2559 zoonref. All rights reserved.
//

import UIKit

protocol Line {
    func duration() -> NSTimeInterval
}

protocol AnimationLine: Line {
    func animate(fromView: UIView, toView: UIView, inView: UIView, direction: Direction)
    func animatePassenger(view: UIView, targetFrame: CGRect, direction: Direction)
}

protocol CADisplayLinkLine: Line {
    
}