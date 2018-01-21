//
//  FBItemCategory.swift
//  PriceBar
//
//  Created by Leonid Nifantyev on 6/28/17.
//  Copyright © 2017 LionLife. All rights reserved.
//

import Foundation


class FBItemCategory {
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


func == (lhs: FBItemCategory, rhs: FBItemCategory) -> Bool {
    var returnValue = false
    if (lhs.name == rhs.name) && (lhs.id == rhs.id) {
        returnValue = true
    }
    return returnValue
}





//class ShopItem  {
//    var id = ""
//    var name = ""
//    var quantity = 0.0
//    var price = 0.0
//    var minPrice = 0.0
//
//    var itemCategory: CategoryModelView?
//    var itemUom: UomModelView?
//    var outletId = ""
//    var scanned = false
//    var checked = false
//
//    init(id: String, name: String,
//         quantity: Double, minPrice: Double,
//         price: Double, itemCategory: CategoryModelView,
//         itemUom: UomModelView, outletId: String, scanned: Bool, checked: Bool) {
//        self.id = id
//        self.name = name
//        self.quantity = quantity
//        self.minPrice = minPrice
//        self.price = price
//        self.itemCategory = itemCategory
//        self.itemUom = itemUom
//        self.outletId = outletId
//        self.scanned = scanned
//        self.checked = checked
//
//    }
//
////    init(id: String, goodData: Dictionary<String, Any>) {
////        self.id = id
////        if let name = goodData["name"] as? String {
////            self.name = name
////        } else {
////            self.name = ""
////
////        }
////
////        if let catId = goodData["category_id"] as? Int32 {
////            guard let cat = CoreDataService.data.getCategory(by: catId),
////                let categoryName = cat.category else {
////                fatalError("Category is not found")
////            }
////            self.itemCategory = CategoryModel(id: catId, name: categoryName)
////        } else {
////            guard let cat = CoreDataService.data.getCategory(by: 1),
////                let categoryName = cat.category else {
////                    fatalError("Category is not found")
////            }
////            self.itemCategory = CategoryModel(id: 1, name: categoryName)
////        }
////
////        if let uomId = goodData["uom_id"] as? Int32 {
////            guard let uom = CoreDataService.data.getUom(by: uomId),
////                let uomName = uom.uom else {
////                    fatalError("Uom is not found")
////            }
////            self.itemUom = UomModel(id: uomId, name: uomName)
////
////        } else {
////            guard let uom = CoreDataService.data.getUom(by: 1),
////                let uomName = uom.uom else {
////                    fatalError("Category is not found")
////            }
////            self.itemUom = UomModel(id: 1, name: uomName)
////        }
////        self.quantity = 0
////        self.minPrice = 0
////        self.price = 0
////        self.outletId = ""
////        self.scanned = false
////        self.checked = false
////    }
////    init(id: String, priceData: Dictionary<String, Any>) {
////        self.id = id
////        if let price = priceData["price"] as? Double, let outletId = priceData["outlet_id"] as? String {
////
////            self.price = price
////            self.outletId = outletId
////        } else {
////            self.price = 0
////            self.outletId = ""
////
////        }
////        self.name = ""
////        self.quantity = 0
////        self.minPrice = 0
////        //self.itemCategory = ItemCategory()
////        self.itemUom = ItemUom()
////
////        self.scanned = false
////        self.checked = false
////    }
////    var total: Double {
////        return quantity * price
////    }
//}

//copying from one object to other (by value, not reference)
//extension ShopItem: NSCopying {
//    func copy(with zone: NSZone? = nil) -> Any {
//        let copy = ShopItem(id: id, name: name, quantity: quantity, minPrice: minPrice, price: price, itemCategory: itemCategory!, itemUom:itemUom, outletId: outletId, scanned: scanned, checked: checked)
//        return copy
//    }
//}


//extension ShopItem: Equatable {}
//func ==(left: ShopItem, right: ShopItem) -> Bool {
//    return left.id == right.id
//}

