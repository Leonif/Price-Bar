//
//  FBUomModel.swift
//  PriceBar
//
//  Created by Leonid Nifantyev on 1/24/18.
//  Copyright © 2018 LionLife. All rights reserved.
//

import Foundation
import CoreData

struct FBUomModel {
    var id: Int32
    var name: String
    var iterator: Double
    
    var koefficients: [Double]
    var suffixes: [String]
    
    var parameters: [Parameter]
    
}


public class CDParameter: NSObject, NSCoding {
    var maxValue: Int
    var step: Double
    var suffix: String
    var viewMultiplicator: Double
    
    required convenience public init?(coder aDecoder: NSCoder) {
        guard
        let suffix = aDecoder.decodeObject(forKey: "suffix") as? String
            else { return nil }
        let maxValue = aDecoder.decodeInteger(forKey: "maxValue")
        let step = aDecoder.decodeDouble(forKey: "step")
        let mult = aDecoder.decodeDouble(forKey: "viewMultiplicator")
        
        self.init(maxValue: maxValue,
                  step: step,
                  suffix: suffix,
                  viewMultiplicator: mult)
    }
    
    public func encode(with aCoder: NSCoder) {
        aCoder.encodeCInt(Int32(self.maxValue), forKey: "maxValue")
        aCoder.encode(self.step, forKey: "step")
        aCoder.encode(self.suffix, forKey: "suffix")
        aCoder.encode(self.viewMultiplicator, forKey: "viewMultiplicator")
        
    }
    
    
    init(maxValue: Int, step: Double, suffix: String, viewMultiplicator:Double) {
        self.maxValue = maxValue
        self.step = step
        self.suffix = suffix
        self.viewMultiplicator = viewMultiplicator
    }
    
}




struct Parameter {
    var maxValue: Int
    var step: Double
    var suffix: String
    var viewMultiplicator: Double
}

