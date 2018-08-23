//
//  FBUomModel.swift
//  PriceBar
//
//  Created by Leonid Nifantyev on 1/24/18.
//  Copyright © 2018 LionLife. All rights reserved.
//

import Foundation
import CoreData

struct UomEntity {
    var id: Int32
    var name: String
    var iterator: Double
    var koefficients: [Double]
    var suffixes: [String]
    var parameters: [Parameter]
}

struct Parameter {
    var maxValue: Int
    var step: Double
    var suffix: String
    var viewMultiplicator: Double
}

