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
    
    init(type: QuantityType, currentValue: Double) {
        self.type = type
        self.wholeItem = currentValue.int
        
        let decStr = String(format:"%.3f", currentValue).components(separatedBy: ".")
        guard let dec = decStr[1].int else {
            fatalError("String convertion error")
        }
        self.decimalItem = dec
    }
    
}
