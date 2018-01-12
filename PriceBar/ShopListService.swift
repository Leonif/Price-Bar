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


enum ShopListServiceError: Error {
    case syncError(String)
}



class ShopListService {
    
    var shopList = [String: [ShopItem]]()
    var sections = [String]()
    var categories = [ItemCategory]()
    var uoms = [ItemUom]()
    
    var total: Double {
        var sum = 0.0
        shopList.forEach { section in
            section.value.forEach { item in
                sum += item.total
            }
        }
        
        return sum
    }

    
    public func syncCloud(completion: @escaping (ResultType<Bool, ShopListServiceError>)->()) {
        
        var r = (false, false, false,false)
        
        
        
        syncCategories { result in
            switch result {
            case .success:

                r.0 = true
                //                if r == (true,true,true,true) {
                //                    completion(ResultType.success(true))
                //                }
                
                self.syncProducts { result in
                    switch result {
                    case .success:
                        r.1 = true
                        if r == (true,true,true,true) {
                            completion(ResultType.success(true))
                        }
                    case let .failure(error):
                        completion(ResultType.failure(ShopListServiceError.syncError(error.localizedDescription)))
                    }
                }
                
                
                
                
            case let .failure(error):
                completion(ResultType.failure(ShopListServiceError.syncError(error.localizedDescription)))
            }
        }
        
        
        syncStatistics { result in
            switch result {
            case .success:
                r.2 = true
                if r == (true,true,true,true) {
                    completion(ResultType.success(true))
                }
            case let .failure(error):
                completion(ResultType.failure(ShopListServiceError.syncError(error.localizedDescription)))
            }
        }
        
        syncUom { result in
            switch result {
            case .success:
                r.3 = true
                if r == (true,true,true,true) {
                    completion(ResultType.success(true))
                }
            case let .failure(error):
                completion(ResultType.failure(ShopListServiceError.syncError(error.localizedDescription)))
            }
        }
    }
    
    
    private func syncCategories(completion: @escaping (ResultType<Bool, ShopListServiceError>)->())  {
        CoreDataService.data.syncCategories { result in
            switch result {
            case .success:
                completion(ResultType.success(true))
            case let .failure(error):
                completion(ResultType.failure(ShopListServiceError.syncError(error.localizedDescription)))
            }
        }
    }

    private func syncProducts(completion: @escaping (ResultType<Bool, ShopListServiceError>)->())  {
        CoreDataService.data.syncProducts { result in // get from firebase
            switch result {
            case .success:
                completion(ResultType.success(true))
            case let .failure(error):
                completion(ResultType.failure(.syncError(error.localizedDescription)))
            }
        }
    }
    
    
    private func syncStatistics(completion: @escaping (ResultType<Bool, ShopListServiceError>)->())  {
        CoreDataService.data.syncProducts { result in // get from firebase
            switch result {
            case .success:
                completion(ResultType.success(true))
            case let .failure(error):
                completion(ResultType.failure(.syncError(error.localizedDescription)))
            }
        }
    }
    
    
    private func syncUom(completion: @escaping (ResultType<Bool, ShopListServiceError>)->())  {
        CoreDataService.data.syncUoms { result in // get from firebase
            switch result {
            case .success:
                completion(ResultType.success(true))
            case let .failure(error):
                completion(ResultType.failure(.syncError(error.localizedDescription)))
            }
        }
    }

    
    
    
    
    
    
    
    
    func reloadDataFromCoreData(for outledId: String) {
        let itemList = getShopItems(for: outledId)
        
        sections = []
        shopList.removeAll()
        itemList?.forEach { item in
            if sections.contains(item.itemCategory.name) {
                shopList[item.itemCategory.name]?.append(item)
            } else {
                sections.append(item.itemCategory.name)
                shopList[item.itemCategory.name] = [item]
            }
        }
    }
    
    func getShopItems(for outletId: String) -> [ShopItem]?  {
        if let itemList = CoreDataService.data.getItemList(for: outletId) {
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
        shopList.forEach { section in
            section.value.forEach { item in
                item.price = CoreDataService.data.getPrice(for: item.id, and:outletId)
                item.outletId = outletId
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
    
    func removeAllItems() {
        
        shopList.removeAll()
        CoreDataService.data.removeAllItems()
        
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
        var updatedShopList = [String: [ShopItem]]()
        var updatedSections = [String]()
        shopList.forEach { section in
            section.value.forEach { item in
                if updatedSections.contains(item.itemCategory.name) {
                    updatedShopList[item.itemCategory.name]?.append(item)
                } else {
                    updatedSections.append(item.itemCategory.name)
                    updatedShopList[item.itemCategory.name] = [item]
                }
            }
        }
        shopList = updatedShopList
        sections = updatedSections
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





