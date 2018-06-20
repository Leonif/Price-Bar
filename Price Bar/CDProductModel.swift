//
//  CDProductModel.swift
//  PriceBar
//
//  Created by Leonid Nifantyev on 1/20/18.
//  Copyright © 2018 LionLife. All rights reserved.
//

import Foundation

struct CDProductModel {
    var id: String
    var name: String
    var brand: String
    var weightPerPiece: String
    var categoryId: Int32
    var uomId: Int32
}

struct CDShoplistItem {
    var productId: String
    var productName: String
    var brand: String
    var weightPerPiece: String
    var categoryId: Int32
    var productCategory: String
    var uomId: Int32
    var productUom: String
    var quantity: Double
    var checked: Bool
    
    var parameters: [Parameter]
}
