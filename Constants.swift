//
//  Enums.swift
//  PriceBar
//
//  Created by Leonid Nifantyev on 6/10/17.
//  Copyright © 2017 LionLife. All rights reserved.
//

import Foundation


enum AppCons: String {
    case showProductCard = "showProductCard"
    case showOutlets = "showOutlets"
    case showScan = "showScan"
    case showItemList = "showItemList"
}

class CodesDB {
    static let db = CodesDB()
    
    var barcodes:[String:String] = ["0671860013624":"Арбуз","9501101530003":"Сметана"]
    func getItem(by code: String, by outletId: String) -> ShopItem {
        
        let um = ShopItemUom()
        
        return ShopItem(id: code, name: code, quantity: 1, price: 0.0, category: code, uom: um, outletId: outletId, scanned: false)
    }
    
}











