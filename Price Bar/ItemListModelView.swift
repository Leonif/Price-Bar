//
//  ItemListModelView.swift
//  PriceBar
//
//  Created by Leonid Nifantyev on 1/27/18.
//  Copyright © 2018 LionLife. All rights reserved.
//

struct ItemListModelView {
    var id: String
    var product: String
    var brand: String
    var weightPerPiece: String
    var currentPrice: Double
    var categoryName: String
    
    var fullName: String {
        
        let pr = "\(product)"
        let br = brand.isEmpty ? "" : ", \(brand)"
        let w = weightPerPiece.isEmpty ? "" : ", \(weightPerPiece)"
        
        return "\(pr)\(br)\(w)"
    }
    
}
