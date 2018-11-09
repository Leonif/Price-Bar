//
//  FBUomModel.swift
//  PriceBar
//
//  Created by Leonid Nifantyev on 1/24/18.
//  Copyright © 2018 LionLife. All rights reserved.
//

import Foundation
import CoreData

struct UomEntity: Decodable {
    var id: Int32?
    var name: String
//    var iterator: Double
    var koefficients: [Double]? // fill later
    var suffixes: [String]? // fille later
    var parameters: [ParameterEntity?]
    var params: [ParameterEntity] {
        return parameters.compactMap { $0 }
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case koefficients
        case suffixes
        case parameters = "parameters2"
    }
    

    init(id: Int32 = -1,
         name: String = "No name",
         koefficients: [Double] = [],
         suffixes: [String] = [],
         parameters: [ParameterEntity] = []) {

        self.id = id
        self.name = name
        self.koefficients = koefficients
        self.suffixes = suffixes
        self.parameters = parameters
    }

}

struct ParameterEntity: Decodable {
    var maxValue: Int
    var step: Double
    var suffix: String
//    var viewMultiplicator: Double
    var divider: Double?
    
    enum CodingKeys: String, CodingKey {
        case divider
//        case viewMultiplicator = "view_multiplicator"
        case suffix
        case step
        case maxValue = "max"
    }
}
