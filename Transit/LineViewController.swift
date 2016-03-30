//
//  LineViewController.swift
//  Transit
//
//  Created by Amornchai Kanokpullwad on 3/27/2559 BE.
//  Copyright © 2559 zoonref. All rights reserved.
//

import UIKit

class LineViewController: UITableViewController {
    
    var selectedIndexPath: NSIndexPath?
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selectedIndexPath = indexPath
        if indexPath.row == 0 {
            let animationVC = storyboard?.instantiateViewControllerWithIdentifier("AnimationVC")
            travelPushBy(SlideInZoomOutAnimation(), to: animationVC!)
        } else if indexPath.row == 1 {
            let progressVC = storyboard?.instantiateViewControllerWithIdentifier("ProgressVC")
            travelPushBy(SlideInZoomOutProgress(), to: progressVC!)
        }
    }
    
    private var transit: Transit?
    private var panStart: CGFloat = 0
    
    @IBAction func handlePan(sender: UIPanGestureRecognizer) {
        let view = sender.view!
        let location = sender.locationInView(view.window)
        let velocity = sender.velocityInView(view)
        
        if sender.state == .Began {
            selectedIndexPath = NSIndexPath(forRow: 2, inSection: 0)
            panStart = location.x
            let interactionVC = storyboard?.instantiateViewControllerWithIdentifier("InteractionVC")
            transit = travelPushBy(SlideInZoomOutInteraction(),
                to: interactionVC!, normalLine: SlideInZoomOutProgress())
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

extension LineViewController: StationPassenger {
    
    func allPassengers() -> [Passenger] {
        if let indexPath = selectedIndexPath {
            let view = tableView.cellForRowAtIndexPath(indexPath)!.viewWithTag(1)!
            return [Passenger(name: "icon", view: view)]
        }
        return []
    }
}