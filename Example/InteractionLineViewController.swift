//
//  InteractionLineViewController.swift
//  Transit
//
//  Created by Amornchai Kanokpullwad on 3/30/2559 BE.
//  Copyright © 2559 zoonref. All rights reserved.
//

import UIKit
import Transit

class InteractionLineViewController: UITableViewController {
    
    override func viewDidLoad() {
        let panGesture = UIPanGestureRecognizer(target: self,
            action: #selector(InteractionLineViewController.handlePan(_:)))
        view.addGestureRecognizer(panGesture)
    }

    private var transit: Transit?
    private var panStart: CGFloat = 0
    
    func handlePan(sender: UIPanGestureRecognizer) {
        let location = sender.locationInView(view.window)
        let velocity = sender.velocityInView(view)
        
        if sender.state == .Began {
            panStart = location.x
            transit = travelPopBy(SlideInZoomOutInteraction())
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

extension InteractionLineViewController: StationPassenger {
    
    func allPassengers() -> [Passenger] {
        let view = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0))!.viewWithTag(1)!
        return [Passenger(name: "icon", view: view)]
    }
}