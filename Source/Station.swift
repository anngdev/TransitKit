//
//  Station.swift
//  Transit
//
//  Created by Amornchai Kanokpullwad on 3/5/2559 BE.
//  Copyright © 2559 zoonref. All rights reserved.
//

import UIKit

typealias Station = UIViewController

extension UIViewController {
    
    func travelBy(line: Line, to: Station, with: [Passenger] = []) {
        let train = Train(from: self, to: to, passengers: with)
        let transit = Transit(line: line, train: train, direction: .Go)
        
        to.transitioningDelegate = transit
        presentViewController(to, animated: true, completion: nil)
    }
    
    func travelBackBy(line: Line, with: [Passenger] = []) {
        let train = Train(from: self, to: presentingViewController!, passengers: with)
        let transit = Transit(line: line, train: train, direction: .Return)
        transitioningDelegate = transit
        dismissViewControllerAnimated(true, completion: nil)
    }
}

// MARK: - Passenger

protocol StationPassenger {
    func allPassengers() -> [Passenger]
}

extension StationPassenger {
    func passengerByName(name: String) -> Passenger? {
        for passenger in allPassengers() {
            if passenger.name == name {
                return passenger
            }
        }
        return nil
    }
}