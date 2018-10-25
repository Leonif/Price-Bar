//
//  ShoplistViewItem.swift
//  PriceBar
//
//  Created by Leonid Nifantyev on 1/20/18.
//  Copyright © 2018 LionLife. All rights reserved.
//

import Foundation

struct ShoplistViewItem: Equatable {
    var productId: String
    var country: String
    var productName: String
    var brand: String
    var weightPerPiece: String
    var categoryId: Int32
    var productCategory: String
    var productPrice: Double
    var uomId: Int32
    var productUom: String
    var quantity: Double
    var parameters: [ParameterEntity]

    var fullName: String {
        let pr = "\(productName)"
        let br = brand.isEmpty ? "" : ", \(brand)"
        let weightToShow = weightPerPiece.isEmpty ? "" : ", \(weightPerPiece)"

        return "\(pr)\(br)\(weightToShow) - \(country)"
    }

    init(productId: String = "", country: String = "",
         productName: String = "", brand: String = "", weightPerPiece: String = "",
         categoryId: Int32 = -1, productCategory: String = "",
         productPrice: Double = -1.0, uomId: Int32 = -1,
         productUom: String = "", quantity: Double = -1.0, parameters: [ParameterEntity] = []) {
        self.productId = productId
        self.country = country
        self.productName = productName
        self.brand = brand
        self.weightPerPiece = weightPerPiece
        self.categoryId = categoryId
        self.productCategory = productCategory
        self.productPrice = productPrice
        self.uomId = uomId
        self.productUom = productUom
        self.quantity = quantity
        self.parameters = parameters
    }
}

func ==(lhs: ShoplistViewItem, rhs: ShoplistViewItem) -> Bool {
    return lhs.productId == rhs.productId
}
