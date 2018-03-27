//
//  StatisticModel.swift
//  PriceBar
//
//  Created by Leonid Nifantyev on 3/26/18.
//  Copyright © 2018 LionLife. All rights reserved.
//

import Foundation

public struct StatisticModel {
    var productId: String = ""
    
    var outlets: [OPOutletModel] = []
    var prices: [Double] = []
    
    
    mutating func append(_ outlet: OPOutletModel, _ price: Double) {
        self.outlets.append(outlet)
        self.prices.append(price)
    }
    
    
}
