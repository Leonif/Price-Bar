//
//  DPShoplistItemModel.swift
//  PriceBar
//
//  Created by Leonid Nifantyev on 1/20/18.
//  Copyright © 2018 LionLife. All rights reserved.
//

import Foundation

struct DPShoplistItemModel: Equatable {
    var productId: String
    var productName: String
    var categoryId: Int32
    var productCategory: String
    var productPrice: Double
    var uomId: Int32
    var productUom: String
    var quantity: Double
    var checked: Bool
    
    var parameters: [Parameter]
}

func ==(lhs: DPShoplistItemModel, rhs: DPShoplistItemModel) -> Bool {
    return lhs.productId == rhs.productId// && lhs.productCategory == rhs.productCategory
}
