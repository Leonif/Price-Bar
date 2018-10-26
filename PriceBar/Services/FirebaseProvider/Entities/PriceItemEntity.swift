//
//  FBItemStatisticEntity.swift
//  PriceBar
//
//  Created by Leonid Nifantyev on 1/21/18.
//  Copyright © 2018 LionLife. All rights reserved.
//

import Foundation





struct BarcodeBounds: Decodable {
    var lower: String
    var upper: String
    var country: String
    
    enum CodingKeys: String, CodingKey {
        case lower = "lower_bound"
        case upper = "upper_bound"
        case country
    }
}





struct PriceItemEntity: Decodable {
    var productId: String?
    var price: Double
    var outletId: String
    var date: Date? {
        return strDate.toDate(with: "dd.MM.yyyy HH:mm:ss") ?? Date()
    }
    var strDate: String
    enum CodingKeys: String, CodingKey {
        case productId = "product_id"
        case price
        case outletId = "outlet_id"
        case strDate = "date"
    }

    #warning("Check is it uses anywere?")
    init?(priceData: Dictionary<String, Any>) {
        guard
            let price = priceData["price"] as? Double,
            price != 0,
            let outletId = priceData["outlet_id"] as? String,
            let dateStr = priceData["date"] as? String  else {
                return nil
        }
        self.price = price
        self.outletId = outletId
//        self.date = dateStr.toDate(with: "dd.MM.yyyy HH:mm:ss")!
        self.productId = "?????"
        self.strDate = ""
        
    }

    init(productId: String, price: Double, outletId: String) {
        self.productId = productId
        self.price = price
        self.outletId = outletId
//        self.date = Date()
        self.strDate = ""
    }
}


extension PriceItemEntity: Hashable {
    static func == (lhs: PriceItemEntity, rhs: PriceItemEntity) -> Bool {
        return lhs.outletId == rhs.outletId && lhs.productId == rhs.productId
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(outletId)
        hasher.combine(productId)
    }
}
