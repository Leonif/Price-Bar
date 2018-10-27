//
//  ProductEntity.swift
//  PriceBar
//
//  Created by Leonid Nifantyev on 1/15/18.
//  Copyright © 2018 LionLife. All rights reserved.
//

import Foundation

struct ProductEntity: Decodable {
    var productId: String
    var name: String
    var brand: String?
    var weightPerPiece: String?
    var categoryId: Int32?
    var uomId: Int32?

    
    enum CodingKeys: String, CodingKey {
        case productId = "barcode"
        case name
        case categoryId = "category_id"
        case uomId = "uom_id"
        case brand
        case weightPerPiece = "weight_per_piece"
    }
    
    
    
    var fullName: String {
        let pr = "\(name)"
        
        var brandToShow = ""
        
        if let brand = brand {
            brandToShow = brand
        }
        
        var weightToShow = ""
        
        if let weightPerPiece = weightPerPiece {
            weightToShow = weightPerPiece
        }

        return "\(pr)\(brandToShow)\(weightToShow)"
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
