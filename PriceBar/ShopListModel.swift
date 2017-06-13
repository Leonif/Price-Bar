//
//  ShopListModel.swift
//  Price Bar
//
//  Created by Leonid Nifantyev on 6/4/17.
//  Copyright © 2017 LionLife. All rights reserved.
//

import Foundation

enum SectionInfo {
    case sectionEmpty
    case sectionFull
    case indexError
}


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
    
    func remove(item: ShopItem) -> SectionInfo {
        for (key, value) in shopList {
            if let index = value.index(of: item) {
                shopList[key]!.remove(at: index)
                if shopList[key]?.count == 0 {
                    sections = sections.filter{$0 != key}
                    shopList.removeValue(forKey: key)
                    return .sectionEmpty
                    
                }
            }
            
        }
        return .sectionFull
    }
    
    func change(item: ShopItem) {
        for (key, value) in shopList {
            if let index = value.index(of: item) {
                shopList[key]?[index] = item
            }
        }
        updateSections()
    }
    
    func updateSections() {
        
        var tempList = [String: [ShopItem]]()
        var temSec = [String]()
        
        shopList.forEach {
            $0.value.forEach {
                if temSec.contains($0.category) {
                    tempList[$0.category]?.append($0)
                } else {
                    temSec.append($0.category)
                    tempList[$0.category] = [$0]
                }
            }
        }
        shopList = tempList
        sections = temSec
    }
    
    
    func getItem(index: IndexPath) -> ShopItem? {
        
        if index.section-1 <= sectionCount {
            if let items = shopList[sections[index.section]]  {
                return items[index.row]
            }
        }
        return nil
        
    }
    
    func rowsIn(_ section: Int) -> Int {
        return shopList[sections[section]]?.count ?? 0
        
    }
    
    var sectionCount: Int {
        
        return shopList.keys.count
        
    }
    
    
    
    
    func headerString(for section: Int) -> String {
        return sections[section]
    }
}




class ShopItem  {
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

//copying from one object to other (by value, not reference)
extension ShopItem: NSCopying {
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = ShopItem(id: id, name: name, quantity: quantity, price: price, category: category)
        return copy
    }
}


extension ShopItem: Equatable {}
func ==(left: ShopItem, right: ShopItem) -> Bool {
    return left.id == right.id
}
