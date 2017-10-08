//
//  ShopListModel.swift
//  Price Bar
//
//  Created by Leonid Nifantyev on 6/4/17.
//  Copyright © 2017 LionLife. All rights reserved.
//

import Foundation
import UIKit

enum SectionInfo {
    case sectionEmpty
    case sectionFull
    case indexError
}

class ShopListModel {
    
    var shopList = [String: [ShopItem]]()
    var sections = [String]()
    var categories = [ItemCategory]()
    var uoms = [ItemUom]()
    
    var total: Double {
        var sum = 0.0
        shopList.forEach { $0.value.forEach { sum += $0.total } }
        return sum
    }
    
    func synchronizeCloud(completion: @escaping ()->()) {
        let deviceStorage = CoreDataService.data

        deviceStorage.getCategories { (categories) in
            categories.forEach { self.categories.append($0) }
            deviceStorage.getUoms { (uoms) in
                uoms.forEach { self.uoms.append($0)  }
                deviceStorage.importItemsFromCloud {
                    deviceStorage.importPricesFromCloud {
                        completion()
                    }
                }
            }
        }
    }
    
    func synchronizeDevice() {
        let deviceStorage = CoreDataService.data
        
        deviceStorage.getCategories { (categories) in
            categories.forEach { self.categories.append($0) }}
        deviceStorage.getUoms { (uoms) in
            uoms.forEach { self.uoms.append($0)  }}
        
    }
    
    
    
    func reloadDataFromCoreData(for outledId: String) {
        
       let shpLst = CoreDataService.data.getItemList(outletId: outledId)
        
        sections = []
        shopList.removeAll()
        shpLst?.forEach {
            if sections.contains($0.itemCategory.name) {
                shopList[$0.itemCategory.name]?.append($0)
            } else {
                sections.append($0.itemCategory.name)
                shopList[$0.itemCategory.name] = [$0]
            }
        }
    }
    
    func getShopItems(outletId: String) -> [ShopItem]?  {
        if let itemList = CoreDataService.data.getItemList(outletId: outletId) {
            return itemList
        }
        return nil
    }
    
    func append(_ item: ShopItem) {
        if sections.contains(item.itemCategory.name) {
            shopList[item.itemCategory.name]?.append(item)
        } else {
            sections.append(item.itemCategory.name)
            shopList[item.itemCategory.name] = [item]
        }
    }
    
    func pricesUpdate(by outletId: String) {
        shopList.forEach{
            $0.value.forEach{
                $0.price = CoreDataService.data.getPrice(for: $0.id, and:outletId)
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
    
    func change(_ item: ShopItem) -> Bool {
        for (key, value) in shopList {
            if let index = value.index(of: item) {
                shopList[key]?[index] = item
                return true
            }
        }
        return false
    }
    
    
    
    
    func updateSections() {
        var tempList = [String: [ShopItem]]()
        var temSec = [String]()
        shopList.forEach {
            $0.value.forEach {
                if temSec.contains($0.itemCategory.name) {
                    tempList[$0.itemCategory.name]?.append($0)
                } else {
                    temSec.append($0.itemCategory.name)
                    tempList[$0.itemCategory.name] = [$0]
                }
            }
        }
        shopList = tempList
        sections = temSec
    }
    
    func getItem(index: IndexPath) -> ShopItem? {
        
        if index.section < self.sectionCount {
            if let items = shopList[self.sections[index.section]]  {
                return items[index.row]
            }
        }
        return nil
        
    }
    
//    func getItem(_ item: ShopItem) -> ShopItem? {
//
//        for (key, value) in shopList {
//            if let index = value.index(of: item) {
//                return shopList[key]?[index]
//            }
//        }
//
//        return nil
//    }
    
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





