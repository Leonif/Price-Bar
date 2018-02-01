//
//  QuantityModel.swift
//  PriceBar
//
//  Created by Leonid Nifantyev on 1/6/18.
//  Copyright © 2018 LionLife. All rights reserved.
//

import Foundation

enum QuantityType {
    case weight, quantity
}
struct QuantityModel {
    var type: QuantityType
    var wholeItem: Int
    var decimalItem: Int
    var indexPath: IndexPath

    init(for cellWithIndexPath: IndexPath, with type: QuantityType, and currentValue: Double) {
        self.type = type
        self.wholeItem = currentValue.int
        self.indexPath = cellWithIndexPath

        let decStr = String(format:"%.3f", currentValue).components(separatedBy: ".")
        guard let dec = decStr[1].int else {
            fatalError("String convertion error")
        }
        self.decimalItem = dec
    }
}

struct QuantityModel2 {
    var suffixes: [String]
    var koefficients: [Double]
}
