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
    var productName: String = ""

    var outlet: OutletEntity
    var price: Double
    var date: Date
}
