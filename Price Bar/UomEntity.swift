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
    var parameters: [ParameterEntity]
    
    init(id: Int32 = -1,
         name: String = "No name",
         iterator: Double = -1,
         koefficients: [Double] = [],
         suffixes: [String] = [],
         parameters: [ParameterEntity] = []) {
        
        self.id = id
        self.name = name
        self.iterator = iterator
        self.koefficients = koefficients
        self.suffixes = suffixes
        self.parameters = parameters
    }
    
    
}

struct ParameterEntity {
    var maxValue: Int
    var step: Double
    var suffix: String
    var viewMultiplicator: Double
    var divider: Double
}

