//
//  ProgressLineViewController.swift
//  Transit
//
//  Created by Amornchai Kanokpullwad on 3/28/2559 BE.
//  Copyright © 2559 zoonref. All rights reserved.
//

import UIKit
import Transit

class ProgressLineViewController: UITableViewController {

}

extension ProgressLineViewController: StationPassenger {
    
    func allPassengers() -> [Passenger] {
        let view = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0))!.viewWithTag(1)!
        return [Passenger(name: "icon", view: view)]
    }
}