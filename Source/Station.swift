//
//  Station.swift
//  Transit
//
//  Created by Amornchai Kanokpullwad on 3/5/2559 BE.
//  Copyright © 2559 zoonref. All rights reserved.
//

import UIKit
import ObjectiveC

typealias Station = UIViewController

private struct AssociatedKeys {
    static var transitKey = "transit"
}

extension UIViewController {
    
    func travelBy(line: Line, to: Station) -> Transit {
        let transit = transitBy(line)
        to.transitioningDelegate = transit
        presentViewController(to, animated: true, completion: nil)
        return transit
    }
    
    func travelBackBy(line: Line) -> Transit {
        let transit = transitBy(line)
        transitioningDelegate = transit
        dismissViewControllerAnimated(true, completion: nil)
        return transit
    }
    
    func travelPushBy(line: Line, to: Station) -> Transit {
        assert(!(line is InteractionLine), "please use another method for interaction line")
        let transit = transitBy(line)
        navigationController?.delegate = transit
        navigationController?.pushViewController(to, animated: true)
        return transit
    }
    
    func travelPushBy(line: InteractionLine, to: Station, normalLine: Line) -> Transit {
        assert(!(normalLine is InteractionLine), "normalLine cannot be interaction line")
        let transit = Transit(line: line)
        navigationController?.delegate = transit
        navigationController?.pushViewController(to, animated: true)
        navigationController?.delegate = transitBy(normalLine)
        return transit
    }
    
    func travelPopBy(line: InteractionLine) -> Transit {
        let transit = Transit(line: line)
        let oldDelegate = navigationController?.delegate
        navigationController?.delegate = transit
        navigationController?.popViewControllerAnimated(true)
        navigationController?.delegate = oldDelegate
        return transit
    }
    
    private func transitBy(line: Line) -> Transit {
        let transit = Transit(line: line)
        objc_setAssociatedObject(self, &AssociatedKeys.transitKey, transit, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return transit
    }
}

// MARK: - Passenger

protocol StationPassenger {
    func allPassengers() -> [Passenger]
}

extension StationPassenger {
    func passengerByName(name: String) -> Passenger? {
        return allPassengers().filter{ $0.name == name }.first
    }
}
