//
//  FBItemStatistic.swift
//  PriceBar
//
//  Created by Leonid Nifantyev on 1/21/18.
//  Copyright © 2018 LionLife. All rights reserved.
//

import Foundation

struct FBItemStatistic {
    var productId: String
    var price: Double
    var outletId: String
    var date: Date

    init?(priceData: Dictionary<String, Any>) {
        guard let productId = priceData["product_id"] as? String,
            let price = priceData["price"] as? Double,
            price != 0,
            let outletId = priceData["outlet_id"] as? String,
            let dateStr = priceData["date"] as? String  else {
                return nil
        }

        self.productId = productId
        self.price = price
        self.outletId = outletId
        self.date = dateStr.toDate(with: "dd.MM.yyyy HH:mm:ss")!
    }

    init(productId: String, price: Double, outletId: String) {
        self.productId = productId
        self.price = price
        self.outletId = outletId
        self.date = Date()
    }
}


extension FBItemStatistic: Equatable {
    static func == (lhs: FBItemStatistic, rhs: FBItemStatistic) -> Bool {
        return (lhs.productId == rhs.productId &&
//            lhs.price == rhs.price &&
            lhs.outletId == rhs.outletId)// &&
//            lhs.date == rhs.date)
    }
}
