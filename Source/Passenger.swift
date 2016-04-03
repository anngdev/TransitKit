//
//  Passenger.swift
//  Transit
//
//  Created by Amornchai Kanokpullwad on 3/5/2559 BE.
//  Copyright © 2559 zoonref. All rights reserved.
//

import UIKit

public struct Passenger {
    var name: String
    var view: UIView
    
    public init(name: String, view: UIView) {
        self.name = name
        self.view = view
    }
}