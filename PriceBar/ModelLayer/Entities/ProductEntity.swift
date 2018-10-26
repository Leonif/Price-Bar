//
//  ProductEntity.swift
//  PriceBar
//
//  Created by Leonid Nifantyev on 1/15/18.
//  Copyright © 2018 LionLife. All rights reserved.
//

import Foundation

struct ProductEntity {
    var productId: String
    var name: String
    var brand: String
    var weightPerPiece: String
    var categoryId: Int32
    var uomId: Int32

    var fullName: String {
        let pr = "\(name)"
        let br = brand.isEmpty ? "" : ", \(brand)"
        let weightToShow = weightPerPiece.isEmpty ? "" : ", \(weightPerPiece)"

        return "\(pr)\(br)\(weightToShow)"
    }

    init(productId: String = "", name: String = "", brand: String = "", weightPerPiece: String = "", categoryId: Int32 = 0, uomId: Int32 = 0) {
        self.productId = productId
        self.name = name
        self.brand = brand
        self.weightPerPiece = weightPerPiece
        self.categoryId = categoryId
        self.uomId = uomId
    }
}
