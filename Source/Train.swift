//
//  Train.swift
//  Transit
//
//  Created by Amornchai Kanokpullwad on 3/5/2559 BE.
//  Copyright © 2559 zoonref. All rights reserved.
//

import Foundation

public struct Train {
    
    var fromStation: Station
    var toStation: Station
    var passengers: [Passenger] = []
    
    init(from: Station, to: Station) {
        fromStation = from
        toStation = to
        
        if let station = from as? StationPassenger {
            passengers = station.allPassengers()
        }
    }
}