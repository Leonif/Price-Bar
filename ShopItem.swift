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
    var minPrice = 0.0
    var category = ""
    var uom: ShopItemUom
    var outletId = ""
    var scanned = false
    var checked = false
    
    init(id: String, name: String, quantity: Double, minPrice: Double, price: Double, category: String, uom: ShopItemUom, outletId: String, scanned: Bool, checked: Bool) {
        self.id = id
        self.name = name
        self.quantity = quantity
        self.minPrice = minPrice
        self.price = price
        self.category = category
        self.uom = uom
        self.outletId = outletId
        self.scanned = scanned
        self.checked = checked
        
    }
    
    init(id: String, goodData: Dictionary<String, Any>) {
        self.id = id
        if let name = goodData["name"] as? String {
            
            self.name = name
            
            
        } else {
            self.name = ""
            
        }
        self.quantity = 0
        self.minPrice = 0
        self.price = 0
        self.category = "Неопредленно"
        self.uom = ShopItemUom()
        self.outletId = ""
        self.scanned = false
        self.checked = false
        
        
        
    }



    var total: Double {
        return quantity * price
    }
}

//copying from one object to other (by value, not reference)
extension ShopItem: NSCopying {
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = ShopItem(id: id, name: name, quantity: quantity, minPrice: minPrice, price: price, category: category, uom:uom, outletId: outletId, scanned: scanned, checked: checked)
        return copy
    }
}


extension ShopItem: Equatable {}
func ==(left: ShopItem, right: ShopItem) -> Bool {
    return left.id == right.id
}
