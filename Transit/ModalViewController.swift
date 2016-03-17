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
    
    override func viewDidLoad() {
        let panGesture = UIPanGestureRecognizer(target: self, action: "handlePan:")
        view.addGestureRecognizer(panGesture)
    }
    
    func allPassengers() -> [Passenger] {
        return [Passenger(name: "orange", view: orangeView)]
    }
    
    private var transit: Transit?
    private var panStart: CGFloat = 0
    
    func handlePan(sender: UIPanGestureRecognizer) {
        let location = sender.locationInView(view.window)
        let velocity = sender.velocityInView(view)
        
        if sender.state == .Began {
            panStart = location.x
            transit = travelBackBy(SlideInZoomOutInteraction(), with: allPassengers())
        } else if sender.state == .Changed {
            let percentage = (location.x - panStart) / CGRectGetWidth(view.bounds)
            transit?.updateInteractLine(percentage)
        } else if sender.state == .Ended {
            if velocity.x > 100 {
                transit?.finishInteractionLine()
            } else {
                transit?.cancelInteractionLine()
            }
        }
    }
}
