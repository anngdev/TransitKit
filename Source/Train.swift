//
//  Train.swift
//  Transit
//
//  Created by Amornchai Kanokpullwad on 3/5/2559 BE.
//  Copyright © 2559 zoonref. All rights reserved.
//

import Foundation

struct Train {
    
    var fromStation: Station
    var toStation: Station
    var passengers: [Passenger]
    
    init(from: Station, to: Station) {
        self.init(from: from, to: to, passengers: [])
    }
    
    init(from: Station, to: Station, passengers: [Passenger]) {
        fromStation = from
        toStation = to
        self.passengers = passengers
    }
}