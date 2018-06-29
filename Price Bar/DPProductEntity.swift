//
//  ProductModel.swift
//  PriceBar
//
//  Created by Leonid Nifantyev on 1/15/18.
//  Copyright © 2018 LionLife. All rights reserved.
//

import Foundation

struct DPProductEntity {
    var id: String
    var name: String
    var brand: String
    var weightPerPiece: String
    var categoryId: Int32
    var uomId: Int32
}

// FIXME: remove
struct DPUpdateProductModel {
    var id: String
    var name: String
    var brand: String
    var weightPerPiece: String
    var categoryId: Int32
    var uomId: Int32
}


