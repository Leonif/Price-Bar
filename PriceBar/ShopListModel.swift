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
    
    func readInitData() -> (categories:[Category],uoms: [Uom]) {
        let categories = CoreDataService.data.getCategories()
        let uoms = CoreDataService.data.getUom()
        
        return (categories,uoms)
    }
    
    func getShopItems(outletId: String) -> [ShopItem]?  {
        
        if let itemList = CoreDataService.data.getItemList(outletId: outletId) {
        
        
            return itemList
        
        }
        
        return nil
        
    }
    
    func append(item: ShopItem) {
        if sections.contains(item.category) {
            shopList[item.category]?.append(item)
        } else {
            sections.append(item.category)
            shopList[item.category] = [item]
        }
        CoreDataService.data.addToShopListAndSaveStatistics(item)
        
    }
    
    
    
    func pricesUpdate(by outletId: String) {
        shopList.forEach{
            $0.value.forEach{
                $0.price = CoreDataService.data.getPrice($0.id, outletId:outletId)
                $0.outletId = outletId
            
            }}
    }
    
    func remove(item: ShopItem) -> SectionInfo {
        for (key, value) in shopList {
            if let index = value.index(of: item) {
                shopList[key]?.remove(at: index)
                if shopList[key]?.count == 0 {
                    sections = sections.filter{$0 != key}
                    shopList.removeValue(forKey: key)
                    return .sectionEmpty
                    
                }
            }
            
        }
        return .sectionFull
    }
    
    func change(_ item: ShopItem) {
        
        var found = false
        
        for (key, value) in shopList {
            if let index = value.index(of: item) {
                shopList[key]?[index] = item
                found = true
                
            }
        }
        
        if !found {
            append(item: item)
        }
        
        CoreDataService.data.addToShopListAndSaveStatistics(item)
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


struct ShopItemUom {
    
    var uom = "1 шт"
    var increment = 1.0
    
    
    
}


