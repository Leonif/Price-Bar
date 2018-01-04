//
//  Outlet.swift
//  PriceBar
//
//  Created by Leonid Nifantyev on 1/4/18.
//  Copyright © 2018 LionLife. All rights reserved.
//

import Foundation

class Outlet {
    var id = ""
    var name = ""
    var address = ""
    var distance = 0.0
    
    init(_ id: String, _ name: String, _ address: String, _ distance: Double) {
        self.id = id
        self.name = name
        self.address = address
        self.distance = distance
    }
}
