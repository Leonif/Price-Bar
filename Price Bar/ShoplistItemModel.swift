//
//  ShoplistItemModel.swift
//  PriceBar
//
//  Created by Leonid Nifantyev on 1/15/18.
//  Copyright © 2018 LionLife. All rights reserved.
//

import Foundation

struct ShoplistItemModel: Equatable {
    var productId: String
    var productName: String
    var productCategory: String
    var productPrice: Double
    var quantity: Double
    var checked: Bool
}


func ==(lhs: ShoplistItemModel, rhs: ShoplistItemModel) -> Bool {
    return lhs.productId == rhs.productId && lhs.productCategory == rhs.productCategory
}
