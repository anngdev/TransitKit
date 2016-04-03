//
//  Station.swift
//  Transit
//
//  Created by Amornchai Kanokpullwad on 3/5/2559 BE.
//  Copyright © 2559 zoonref. All rights reserved.
//

import UIKit
import ObjectiveC

public typealias Station = UIViewController

private struct AssociatedKeys {
    static var transitKey = "transit"
}

public extension UIViewController {
    
    /**
     Create transit object and use manually
     
     - parameter line: Line to do animation
     
     - returns: Transit object that just created
     */
    public func transitBy(line: Line) -> Transit {
        let transit = Transit(line: line)
        objc_setAssociatedObject(self, &AssociatedKeys.transitKey, transit, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return transit
    }
    
    /**
     Show modal view controller with specify Line
     
     - parameter line: Line to do animation
     - parameter to:   Destination view controller
     
     - returns: Transit object that just created
     */
    public func travelBy(line: Line, to: Station) -> Transit {
        let transit = transitBy(line)
        to.transitioningDelegate = transit
        presentViewController(to, animated: true, completion: nil)
        return transit
    }
    
    /**
     Dismiss modal view controller with specify Line
     
     - parameter line: Line to do animation
     
     - returns: Transit object that just created
     */
    public func travelBackBy(line: Line) -> Transit {
        let transit = transitBy(line)
        transitioningDelegate = transit
        dismissViewControllerAnimated(true, completion: nil)
        return transit
    }
    
    /**
     Push to view controller with specify line
     
     - parameter line: Line to do animation (use `travelPushBy:to:normalLine` for interactive transition)
     - parameter to:   Destination view controller
     
     - returns: Transit object that just created
     */
    public func travelPushBy(line: Line, to: Station) -> Transit {
        assert(!(line is InteractionLine), "please use another method for interaction line")
        let transit = transitBy(line)
        navigationController?.delegate = transit
        navigationController?.pushViewController(to, animated: true)
        return transit
    }
    
    /**
     Push to view controller with interaction line
     
     - parameter line:       Line to do interaction
     - parameter to:         Destination view controller
     - parameter normalLine: Line to do animation when fallback to non-interactive
     
     - returns: Transit object that just created
     */
    public func travelPushBy(line: InteractionLine, to: Station, normalLine: Line) -> Transit {
        assert(!(normalLine is InteractionLine), "normalLine cannot be interaction line")
        let transit = Transit(line: line)
        navigationController?.delegate = transit
        navigationController?.pushViewController(to, animated: true)
        navigationController?.delegate = transitBy(normalLine)
        return transit
    }
    
    /**
     Pop view controller with interaction line (use navigation `popViewControllerAnimated:` for non-interactive)
     
     - parameter line: Line to do interaction
     
     - returns: Transit object that just created
     */
    public func travelPopBy(line: InteractionLine) -> Transit {
        let transit = Transit(line: line)
        let oldDelegate = navigationController?.delegate
        navigationController?.delegate = transit
        navigationController?.popViewControllerAnimated(true)
        navigationController?.delegate = oldDelegate
        return transit
    }
}

// MARK: - Passenger

/**
 *  Implement this protocol to animate with subview passenger
 */
public protocol StationPassenger {
    
    /**
     All passengers with it's subview and name for this view controller
     
     - returns: list of passengers
     */
    func allPassengers() -> [Passenger]
}

public extension StationPassenger {
    public func passengerByName(name: String) -> Passenger? {
        return allPassengers().filter{ $0.name == name }.first
    }
}
