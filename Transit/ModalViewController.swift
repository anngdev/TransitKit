//
//  ModalViewController.swift
//  Transit
//
//  Created by Amornchai Kanokpullwad on 3/5/2559 BE.
//  Copyright © 2559 zoonref. All rights reserved.
//

import UIKit

class ModalViewController: UIViewController, StationPassenger {

    @IBOutlet weak var orangeView: UIView!
    
    @IBAction func buttonPressed(sender: AnyObject) {
        travelBackBy(SlideInZoomOutProgress(), with: allPassengers())
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        NSLog("Modal viewDidAppear")
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        NSLog("Modal viewDidDisappear")
    }
    
    func allPassengers() -> [Passenger] {
        return [Passenger(name: "orange", view: orangeView)]
    }
}
