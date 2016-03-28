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