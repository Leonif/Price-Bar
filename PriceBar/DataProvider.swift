//
//  DataProvider.swift
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



class DataProvider {

    var sections = [String]()
    var shoplist: [ShoplistItemModel] = []
    
    var total: Double {
        var sum = 0.0
        
        shoplist.forEach { item in
            sum += item.productPrice * item.quantity
        }

        return sum
    }
    
    public func syncCloud(completion: @escaping (ResultType<Bool, ShopListServiceError>)->()) {
        syncCategories { result in
            self.handleCategories(result: result, completion: completion)
        }
    }
    
    
    private func handleCategories(result: ResultType<Bool, ShopListServiceError>, completion: @escaping (ResultType<Bool, ShopListServiceError>)->()) {
        switch result {
        case .success:
            self.syncUom { result in
                self.handleUom(result: result, completion: completion)
            }
        case let .failure(error):
            completion(ResultType.failure(ShopListServiceError.syncError(error.localizedDescription)))
        }
    }
    
    private func handleUom(result: ResultType<Bool, ShopListServiceError>, completion: @escaping (ResultType<Bool, ShopListServiceError>)->()) {
        switch result {
        case .success:
            self.syncProducts { result in
                self.handleProducts(result: result, completion: completion)
            }
        case let .failure(error):
            completion(ResultType.failure(ShopListServiceError.syncError(error.localizedDescription)))
        }
    }
    
    private func handleProducts(result: ResultType<Bool, ShopListServiceError>, completion: @escaping (ResultType<Bool, ShopListServiceError>)->()) {
        switch result {
        case .success:
            self.syncStatistics { result in
                self.handleStatistics(result: result, completion: completion)
            }
        case let .failure(error):
            completion(ResultType.failure(ShopListServiceError.syncError(error.localizedDescription)))
        }
    }
    
    
    private func handleStatistics(result: ResultType<Bool, ShopListServiceError>, completion: (ResultType<Bool, ShopListServiceError>)->()) {
        switch result {
        case .success:
            completion(ResultType.success(true))
        case let .failure(error):
            completion(ResultType.failure(ShopListServiceError.syncError(error.localizedDescription)))
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
        CoreDataService.data.syncStatistics { result in // get from firebase
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
    
    
//    func reloadDataFromCoreData(for outledId: String) {
//        let itemList = getShopItems(for: outledId)
//
//        sections = []
//        shopList.removeAll()
//        itemList?.forEach { item in
//            if sections.contains(item.itemCategory.name) {
//                shopList[item.itemCategory.name]?.append(item)
//            } else {
//                sections.append(item.itemCategory.name)
//                shopList[item.itemCategory.name] = [item]
//            }
//        }
//    }
    
    func getShopItems(for outletId: String) -> [ShopItem]?  {
        if let itemList = CoreDataService.data.getItemList(for: outletId) {
            return itemList
        }
        return nil
    }
    
    func save(new statistic: ItemStatistic) {
        CoreDataService.data.save(new: statistic)
        FirebaseService.data.save(new: statistic)
    }
    
    func saveToShopList(new item: ShoplistItemModel) {
        CoreDataService.data.saveToShopList(item)
        shoplist.append(item)
    }
    
//    func addToShopListAndSaveStatistics(_ item: ShopItem) {
//        CoreDataService.data.addToShopListAndSaveStatistics(item)
//        FirebaseService.data.saveOrUpdate(item)
//    }
    
    
    func getShopItems(with pageOffset: Int, for outletId: String) -> [ShopItem]?  {
        return CoreDataService.data.getShortItemList(for: outletId, offset: pageOffset)
    }
    
    func filterItemList(contains text: String, for outletId: String) -> [ShopItem]? {
        return CoreDataService.data.filterItemList(contains: text, for: outletId)
    }
   
    
    func pricesUpdate(by outletId: String) {
        for (index, item) in shoplist.enumerated() {
            let price = CoreDataService.data.getPrice(for: item.productId, and:outletId)
            shoplist[index].productPrice = price
        }
    }
    
    func remove(item: ShoplistItemModel) {
        guard let index = shoplist.index(of: item) else {
            fatalError("item doesnt exist")
        }
        shoplist.remove(at: index)
    }
    
    func removeAllItems() {
//        shopList.removeAll()
//        CoreDataService.data.removeAllItems()
        
    }
    
    
    
    func change(_ changedItem: ShoplistItemModel) -> Bool {
        if let index = shoplist.index(of: changedItem) {
            shoplist[index] = changedItem
            return true
        }
        return false
    }
    
    
    
    
//    func updateSections() {
//        var updatedShopList = [String: [ShopItem]]()
//        var updatedSections = [String]()
//        shopList.forEach { section in
//            section.value.forEach { item in
//                if updatedSections.contains(item.itemCategory.name) {
//                    updatedShopList[item.itemCategory.name]?.append(item)
//                } else {
//                    updatedSections.append(item.itemCategory.name)
//                    updatedShopList[item.itemCategory.name] = [item]
//                }
//            }
//        }
//        shopList = updatedShopList
//        sections = updatedSections
//    }
    
    func getItem(index: IndexPath) -> ShopItem? {
        if index.section < self.sectionCount {
            if let items = shopList[self.sections[index.section]]  {
                return items[index.row]
            }
        }
        return nil
    }
    
    func getItem(with barcode: String, and outletId: String) -> ProductModel? {
        return CoreDataService.data.getItem(by: barcode, and: outletId)
    }
    
    func getCategoryName(category id: Int32) -> String? {
        guard let category = CoreDataService.data.getCategory(by: id),
            let categoryName = category.category else {
            return nil
        }
        return categoryName
    }
    
    func loadShopList(for outletId: String) {
        guard let list =  CoreDataService.data.loadShopList(for: outletId) else {
            return
        }
        list.forEach { item in
            self.shoplist.append(item)
        }
    }
    
    
    func rowsIn(_ section: Int) -> Int {
        
        
        
        return sections[section].count
    }
    
    var sectionCount: Int {
        return shopList.keys.count
    }
    
    func headerString(for section: Int) -> String {
        return sections[section]
    }
}



extension DataProvider {
    
    func getPrice(for productId: String, and outletId: String) -> Double {
        return CoreDataService.data.getPrice(for: productId, and: outletId)
    }
    
    func getMinPrice(for productId: String, and outletId: String) -> Double  {
        return CoreDataService.data.getMinPrice(for: productId, and: outletId)
        
    }
    
    
}





