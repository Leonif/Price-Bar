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


enum DataProviderError: Error {
    case syncError(String)
    case shoplistAddedNewItem(String)
    
    
    var message: String {
        switch self {
        case .syncError:
            return "Ошибка синхронизации"
        case .shoplistAddedNewItem:
            return "Товар уже есть в списке"
        }
    }
}



class DataProvider {

    var sections = [String]()
    var shoplist: [DPShoplistItemModel] = []
    var products: [DPProductModel] = []
    
    var total: Double {
        var sum = 0.0
        shoplist.forEach { item in
            sum += item.productPrice * item.quantity
        }
        return sum
    }
    
    var defaultCategory: DPCategoryModel? {
        
        guard let cd = CoreDataService.data.defaultCategory else {
            return nil
        }        
        return DPCategoryModel(id: cd.id, name: cd.name)
    }
    
    var defaultUom: DPUomModel? {
        
        guard let cd = CoreDataService.data.defaultUom else {
            return nil
        }

        return DPUomModel(id: cd.id, name: cd.name)
    }
    
    
    public func syncCloud(completion: @escaping (ResultType<Bool, DataProviderError>)->()) {
        
        if !needToSync() {
            completion(ResultType.success(true))
        } else {
            shoplist = CoreDataService.data.loadShopList(fro: nil)
            syncCategories { result in
                self.handleCategories(result: result, completion: completion)
            }
        }
    }
    
    
    func needToSync() -> Bool {
        //need to check
        var times = UserDefaults.standard.integer(forKey: "LaunchedTime")
        switch times {
        case 0:
            times += 1
            UserDefaults.standard.set(times, forKey: "LaunchedTime")
            return true
        case 10:
            times = 0
            UserDefaults.standard.set(times, forKey: "LaunchedTime")
            return true
        default:
            times += 1
            UserDefaults.standard.set(times, forKey: "LaunchedTime")
        }
        return false
        
    }
    
    private func saveShoplist() {
        for item in shoplist {
            CoreDataService.data.saveToShopList(item)
        }
        shoplist.removeAll()
    }
    
    private func handleCategories(result: ResultType<Bool, DataProviderError>, completion: @escaping (ResultType<Bool, DataProviderError>)->()) {
        switch result {
        case .success:
            self.syncUom { result in
                self.handleUom(result: result, completion: completion)
            }
        case let .failure(error):
            completion(ResultType.failure(DataProviderError.syncError(error.localizedDescription)))
        }
    }
    
    private func handleUom(result: ResultType<Bool, DataProviderError>, completion: @escaping (ResultType<Bool, DataProviderError>)->()) {
        switch result {
        case .success:
            self.syncProducts { result in
                self.handleProducts(result: result, completion: completion)
            }
        case let .failure(error):
            completion(ResultType.failure(DataProviderError.syncError(error.localizedDescription)))
        }
    }
    
    private func handleProducts(result: ResultType<Bool, DataProviderError>, completion: @escaping (ResultType<Bool, DataProviderError>)->()) {
        switch result {
        case .success:
            self.syncStatistics { result in
                self.handleStatistics(result: result, completion: completion)
            }
        case let .failure(error):
            completion(ResultType.failure(DataProviderError.syncError(error.localizedDescription)))
        }
    }
    
    
    private func handleStatistics(result: ResultType<Bool, DataProviderError>, completion: (ResultType<Bool, DataProviderError>)->()) {
        switch result {
        case .success:
            saveShoplist() // sync finished - recover shoplist
            completion(ResultType.success(true))
        case let .failure(error):
            completion(ResultType.failure(DataProviderError.syncError(error.localizedDescription)))
        }
    }
    
    
    private func syncCategories(completion: @escaping (ResultType<Bool, DataProviderError>)->())  {
        CoreDataService.data.syncCategories { result in
            switch result {
            case .success:
                completion(ResultType.success(true))
            case let .failure(error):
                completion(ResultType.failure(DataProviderError.syncError(error.localizedDescription)))
            }
        }
    }

    private func syncProducts(completion: @escaping (ResultType<Bool, DataProviderError>)->())  {
        CoreDataService.data.syncProducts { result in // get from firebase
            switch result {
            case .success:
                completion(ResultType.success(true))
            case let .failure(error):
                completion(ResultType.failure(.syncError(error.localizedDescription)))
            }
        }
    }
    
    
    private func syncStatistics(completion: @escaping (ResultType<Bool, DataProviderError>)->())  {
        CoreDataService.data.syncStatistics { result in // get from firebase
            switch result {
            case .success:
                completion(ResultType.success(true))
            case let .failure(error):
                completion(ResultType.failure(.syncError(error.localizedDescription)))
            }
        }
    }
    
    
    private func syncUom(completion: @escaping (ResultType<Bool, DataProviderError>)->())  {
        CoreDataService.data.syncUoms { result in // get from firebase
            switch result {
            case .success:
                completion(ResultType.success(true))
            case let .failure(error):
                completion(ResultType.failure(.syncError(error.localizedDescription)))
            }
        }
    }
    
//    func getShopItems(for outletId: String) -> [ShopItem]?  {
//        if let itemList = CoreDataService.data.getItemList(for: outletId) {
//            return itemList
//        }
//        return nil
//    }
    
    func save(new statistic: DPPriceStatisticModel) {
        
        let cd = CDStatisticModel(productId: statistic.productId,
                                  price: statistic.price,
                                  outletId: statistic.outletId)
        
        CoreDataService.data.save(new: cd)
        
        let fb = FBItemStatistic(productId: statistic.productId,
                               price: statistic.price,
                               outletId: statistic.outletId)
        FirebaseService.data.save(new: fb)
    }
    
    func save(new product: DPUpdateProductModel) {
        let pr = CDProductModel(id: product.id,
                                name: product.name,
                                categoryId: product.categoryId,
                                uomId: product.uomId)
        
        CoreDataService.data.save(pr)
        
        let fb = FBProductModel(id: product.id,
                                name: product.name,
                                categoryId: product.categoryId,
                                uomId: product.uomId)
        FirebaseService.data.saveOrUpdate(fb)
    }
    
    
    func update(_ product: DPUpdateProductModel)  {
        let pr = CDProductModel(id: product.id,
                              name: product.name,
                              categoryId: product.categoryId,
                              uomId: product.uomId)
        
        CoreDataService.data.update(pr)
        
        
        let fb = FBProductModel(id: product.id,
                                name: product.name,
                                categoryId: product.categoryId,
                                uomId: product.uomId)
        FirebaseService.data.saveOrUpdate(fb)
    }
    
    func saveToShopList(new item: DPShoplistItemModel) -> ResultType<Bool, DataProviderError> {
        
        if let _ = shoplist.index(of:item) {
            print("\(item.productName) already in shoplist")
            return ResultType.failure(DataProviderError.shoplistAddedNewItem("Уже в списке"))
        }
        
        shoplist.append(item)
        addSection(for: item)
        CoreDataService.data.saveToShopList(item)
        
        return ResultType.success(true)
    }
    
    
    
    func getShopItems(with pageOffset: Int, for outletId: String) -> [DPProductModel]?  {
        return CoreDataService.data.getProductList(for: outletId, offset: pageOffset)
    }
    
    func filterItemList(contains text: String, for outletId: String) -> [DPProductModel]? {
        return CoreDataService.data.filterItemList(contains: text, for: outletId)
    }
   
    
    func pricesUpdate(by outletId: String) {
        for (index, item) in shoplist.enumerated() {
            let price = CoreDataService.data.getPrice(for: item.productId, and:outletId)
            shoplist[index].productPrice = price
        }
    }
    
    func remove(item: DPShoplistItemModel) {
        guard let index = shoplist.index(of: item) else {
            fatalError("item doesnt exist")
        }
        shoplist.remove(at: index)
        removeSection(with: item.productCategory)
        CoreDataService.data.removeFromShopList(with: item.productId)
    }
    
    
    func removeSection(with name: String) {
        guard let index = sections.index(of: name) else {
            return
        }
        
        for item in shoplist {
            if item.productCategory == name {
                print("section \(name) can't be removed cause contains some items")
                return
            }
        }
        sections.remove(at: index)
    }
    
    
    
    
    func clearShoplist() {
        shoplist.removeAll()
        sections.removeAll()
        CoreDataService.data.removeAll(from: "ShopList")
        
    }
    
    
    
    func change(_ changedItem: DPShoplistItemModel) -> Bool {
        if let index = shoplist.index(of: changedItem) {
            shoplist[index] = changedItem
            return true
        }
        return false
    }
    
    func changeShoplistItem(_ quantity: Double, for product_id: String) {
        for (index, item) in shoplist.enumerated() {
            if item.productId == product_id  {
               shoplist[index].quantity = quantity
            }
        }
        CoreDataService.data.changeShoplistItem(quantity, for: product_id)
    }
    
    
    
    func getItem(index: IndexPath) -> DPShoplistItemModel? {
        let sec = index.section
        let indexInSec = index.row
        
        var productListInsection:[DPShoplistItemModel] = []
        for shopiItem in shoplist {
            if shopiItem.productCategory == sections[sec] {
                productListInsection.append(shopiItem)
            }
        }
        guard !productListInsection.isEmpty else {
            return nil
        }
        
        return productListInsection[indexInSec]
    }
    
    func getItem(with barcode: String, and outletId: String) -> DPProductModel? {
        
        guard let cdModel = CoreDataService.data.getItem(by: barcode, and: outletId) else {
            return nil
        }
        
        guard let uom = CoreDataService.data.getUom(by: cdModel.uomId) else {
            fatalError("Uom is not found in CoreData")
        }
        
        let isPerPiece = uom.iterator.truncatingRemainder(dividingBy: 1) == 0
        
        return DPProductModel(id: cdModel.id,
                              name: cdModel.name,
                              categoryId: cdModel.categoryId,
                              uomId: cdModel.uomId,
                              isPerPiece: isPerPiece)
        
        
    }
    
    func getCategoryList() -> [DPCategoryModel]? {
        
        guard let cdModelList = CoreDataService.data.getCategories() else {
            fatalError("category list is empty")
        }
        var dpModelList: [DPCategoryModel] = []
        
        for category in cdModelList {
            dpModelList.append(mapper(from: category))
        }
        
        return dpModelList
    }
    
    
    func mapper(from cdModel: CDCategoryModel) -> DPCategoryModel {
        
        return DPCategoryModel(id: cdModel.id, name: cdModel.name)
        
    }
    
    
    func getUomList() -> [UomModelView]? {
        
        var uomList: [UomModelView] = []
        
        guard let uoms = CoreDataService.data.getUomList() else {
            return nil
        }
        for uom in uoms {
            
            guard let uomName = uom.uom else {
                fatalError("uomName error")
            }
            
            uomList.append(UomModelView(id: uom.id, name:  uomName))
        }
        return uomList
    }
    
    func getUomName(for id: Int32) -> String? {
        return CoreDataService.data.getUomName(by: id)
    }
    
    func getCategoryName(category id: Int32) -> String? {
        guard let category = CoreDataService.data.getCategory(by: id),
            let categoryName = category.category else {
            return nil
        }
        return categoryName
    }
    
    func loadShopList(for outletId: String) {
        shoplist.removeAll()
        sections.removeAll()
        let list =  CoreDataService.data.loadShopList(fro: outletId)
        list.forEach { item in
            self.shoplist.append(item)
            addSection(for: item)
        }
    }
    
    private func addSection(for item: DPShoplistItemModel) {
        if !sections.contains(item.productCategory) {
            sections.append(item.productCategory)
        }
    }
    
    func rowsIn(_ section: Int) -> Int {
        var count: Int = 0
        for item in shoplist {
            if item.productCategory == sections[section] {
                count += 1
            }
        }
        return count
    }
    
    var sectionCount: Int {
        return sections.count
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





