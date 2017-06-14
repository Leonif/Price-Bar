//
//  OutletModel.swift
//  PriceBar
//
//  Created by Leonid Nifantyev on 6/14/17.
//  Copyright © 2017 LionLife. All rights reserved.
//

import Foundation


class OutetListModel  {
    let baseUrl = "https://api.foursquare.com/v2/venues/"
    let clientId = "NPJDKUKZLFXDST4QCKJXWPLVYC3MCDSEQVQKEBMEZL1WETJM"
    let clientSecret = "MA2OS055BLYF3XOUMXRHWTBBJYGYX3U33VVJE3A4VSYBTJ0X"
    let category = "4bf58dd8d48988d1f9941735" //Food & Drink Shop
    let location = (50.412822, 30.635047)
    var delegate: Exchange!
    
    var outlets = [Outlet]()
    
    
    init() {
    
    }
    
    func getOutlet(index: IndexPath) -> Outlet {
        return outlets[index.row]
    }
    
    var count: Int {
        return outlets.count
    }
    
}


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
