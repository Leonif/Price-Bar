//
//  ProductModel.swift
//  PriceBar
//
//  Created by Leonid Nifantyev on 1/15/18.
//  Copyright © 2018 LionLife. All rights reserved.
//

struct ProductModel {
    var id: String
    var name: String
    var categoryId: Int32
    var uomId: Int32
    var isPerPiece: Bool
}


struct UpdateProductModel {
    var id: String
    var name: String
    var categoryId: Int32
    var uomId: Int32
}

struct PriceStatisticModel {
    var outletId: String
    var productId: String
    var price: Double
}
