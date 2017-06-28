//
//  ShopItem.swift
//  PriceBar
//
//  Created by Leonid Nifantyev on 6/28/17.
//  Copyright © 2017 LionLife. All rights reserved.
//

import Foundation

class ShopItem  {
    var id = ""
    var name = ""
    var quantity = 0.0
    var price = 0.0
    var category = ""
    var uom: ShopItemUom
    var outletId = ""
    var scanned = false
    
    init(id: String, name: String, quantity: Double, price: Double, category: String, uom: ShopItemUom, outletId: String, scanned: Bool) {
        self.id = id
        self.name = name
        self.quantity = quantity
        self.price = price
        self.category = category
        self.uom = uom
        self.outletId = outletId
        self.scanned = scanned
        
    }
    
    
    var total: Double {
        return quantity * price
    }
}

//copying from one object to other (by value, not reference)
extension ShopItem: NSCopying {
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = ShopItem(id: id, name: name, quantity: quantity, price: price, category: category, uom:uom, outletId: outletId, scanned: scanned)
        return copy
    }
}


extension ShopItem: Equatable {}
func ==(left: ShopItem, right: ShopItem) -> Bool {
    return left.id == right.id
}
