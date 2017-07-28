//
//  ShopItem.swift
//  PriceBar
//
//  Created by Leonid Nifantyev on 6/28/17.
//  Copyright © 2017 LionLife. All rights reserved.
//

import Foundation


class ItemCategory {
    var id: Int32 = 0
    var name = ""
    
    init() {
        
    }
    
    init(key: Int32, itemCategoryDict: Dictionary<String, Any>) {
        if let name = itemCategoryDict["name"] as? String {
            self.id = key
            self.name = name
        }
    }
    
    init(id: Int32, name: String) {
        self.id = id
        self.name = name
    }
}

func == (lhs: ItemCategory, rhs: ItemCategory) -> Bool {
    var returnValue = false
    if (lhs.name == rhs.name) && (lhs.id == rhs.id)
    {
        returnValue = true
    }
    return returnValue
}






class ShopItem  {
    var id = ""
    var name = ""
    var quantity = 0.0
    var price = 0.0
    var minPrice = 0.0
    
    var itemCategory = ItemCategory()
    
    var category = ""
    var uom: ShopItemUom
    var outletId = ""
    var scanned = false
    var checked = false
    
    init(id: String, name: String, quantity: Double, minPrice: Double, price: Double, itemCategory: ItemCategory, uom: ShopItemUom, outletId: String, scanned: Bool, checked: Bool) {
        self.id = id
        self.name = name
        self.quantity = quantity
        self.minPrice = minPrice
        self.price = price
        
        self.itemCategory = itemCategory
        //self.category = category
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
        
        if let catId = goodData["category_id"] as? Int32 {
            self.itemCategory.id = catId
            for cat in CoreDataService.data.initCategories {
                if cat.id == catId  {
                    itemCategory.name = cat.name
                    break
                }
            }
        } else {
            itemCategory = CoreDataService.data.initCategories[0]
        }
        
        
        self.quantity = 0
        self.minPrice = 0
        self.price = 0
        
        
        self.uom = ShopItemUom()
        self.outletId = ""
        self.scanned = false
        self.checked = false
    }
    init(id: String, priceData: Dictionary<String, Any>) {
        self.id = id
        if let price = priceData["price"] as? Double, let outletId = priceData["outlet_id"] as? String {
            
            self.price = price
            self.outletId = outletId
        } else {
            self.price = 0
            self.outletId = ""
            
        }
        self.name = ""
        self.quantity = 0
        self.minPrice = 0
        self.itemCategory = ItemCategory()
        self.uom = ShopItemUom()
        
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
        let copy = ShopItem(id: id, name: name, quantity: quantity, minPrice: minPrice, price: price, itemCategory: itemCategory, uom:uom, outletId: outletId, scanned: scanned, checked: checked)
        return copy
    }
}


extension ShopItem: Equatable {}
func ==(left: ShopItem, right: ShopItem) -> Bool {
    return left.id == right.id
}
