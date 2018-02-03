//
//  ProductModel.swift
//  PriceBar
//
//  Created by Leonid Nifantyev on 1/15/18.
//  Copyright © 2018 LionLife. All rights reserved.
//

struct DPProductModel {
    var id: String
    var name: String
    var categoryId: Int32
    var uomId: Int32
}

struct DPUpdateProductModel {
    var id: String
    var name: String
    var categoryId: Int32
    var uomId: Int32
}

struct DPPriceStatisticModel {
    var outletId: String
    var productId: String
    var price: Double
}
