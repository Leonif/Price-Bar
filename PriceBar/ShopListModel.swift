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
    var uoms = [Uom]()
    
    var total: Double {
        var sum = 0.0
        shopList.forEach{$0.value.forEach{sum += $0.total}}
        return sum
    }
    
    deinit {
        print("shopModel is destoyed")
        print("shop model: \(self.categories)")
    }
    
    func reloadDBFromCloud(completion: @escaping ()->()) {
        CoreDataService.data.getCategories { (categories) in
            for c in categories {
                self.categories.append(c)
            }
            self.uoms = CoreDataService.data.getUom()
            CoreDataService.data.importGoodsFromFirebase {
                CoreDataService.data.importPricesFromFirebase {
                    completion()
                }
            }
        }
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
    
    // check if data in core data doesnt exist add them to start work
//    func readInitData(complete:@escaping ()->()) {
//        CoreDataService.data.getCategories { (categories) in
//            for c in categories {
//                self.categories.append(c)
//            }
//            //print("shop model: \(self.categories)")
//            complete()
//            
//        }
//    }
    
    
    
    func getShopItems(outletId: String) -> [ShopItem]?  {
        if let itemList = CoreDataService.data.getItemList(outletId: outletId) {
            return itemList
        }
        return nil
    }
    
    func append(item: ShopItem) {
        if sections.contains(item.itemCategory.name) {
            shopList[item.itemCategory.name]?.append(item)
        } else {
            sections.append(item.itemCategory.name)
            shopList[item.itemCategory.name] = [item]
        }
        print("From ShopListModel(append): addToShopListAndSaveStatistics - addToShopList")
        //CoreDataService.data.addToShopListAndSaveStatistics(item)
        CoreDataService.data.addToShopList(item)
        
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
        print("From ShopListModel (change): addToShopListAndSaveStatistics - addToShopList")
        CoreDataService.data.addToShopListAndSaveStatistics(item)
        updateSections()
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


