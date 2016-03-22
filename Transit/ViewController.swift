//
//  ViewController.swift
//  Transit
//
//  Created by Amornchai Kanokpullwad on 3/5/2559 BE.
//  Copyright © 2559 zoonref. All rights reserved.
//

import UIKit

class ViewController: UIViewController, StationPassenger {

    @IBOutlet weak var orangeView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        NSLog("viewDidAppear")
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        NSLog("viewDidDisappear")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func buttonPressed(sender: AnyObject) {
        let modal = storyboard!.instantiateViewControllerWithIdentifier("ModalViewController")
        travelPushBy(SlideInZoomOutAnimation(), to: modal)
    }
    
    func allPassengers() -> [Passenger] {
        return [Passenger(name: "orange", view: orangeView)]
    }
}

