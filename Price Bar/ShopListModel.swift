//
//  ShopListModel.swift
//  Price Bar
//
//  Created by Leonid Nifantyev on 6/4/17.
//  Copyright © 2017 LionLife. All rights reserved.
//

import Foundation

class ShopListModel {
    
    var shopList = [String: [ShopItem]]()
    var sections = [String]()
    
    var total: Double {
        var sum = 0.0
        shopList.forEach{$0.value.forEach{sum += $0.total}}
        return sum
    }
    
    func append(item: ShopItem) {
        if sections.contains(item.category) {
            shopList[item.category]?.append(item)
        } else {
            sections.append(item.category)
            shopList[item.category] = [item]
        }
    }
    
   
    
    func getItem(index: IndexPath) -> ShopItem {
        return shopList[sections[index.section]]![index.row]
    }
    
    func rowsIn(_ section: Int) -> Int {
        return shopList[sections[section]]?.count ?? 0
    }
    
    var sectionCount: Int {
        shopList.forEach{
            $0.value.forEach{if !sections.contains($0.category) {
                    sections.append($0.category)
                }
            }
        }
        return sections.count
    }
    
    
    func headerString(for section: Int) -> String {
        return sections[section]
    }
}




class ShopItem {
    var id = ""
    var name = ""
    var quantity = 0.0
    var price = 0.0
    var category = ""
    
    
    init(id: String, name: String, quantity: Double, price: Double, category: String) {
        self.id = id
        self.name = name
        self.quantity = quantity
        self.price = price
        self.category = category
    }
    
    
    var uom: String {
        
        return "шт."
    }
    
    var total: Double {
        return quantity * price
    }
    
    
    
    
    
    
}
