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
    case productIsNotFound(String)
    case other(String)

    var message: String {
        switch self {
        case .syncError:
            return "Ошибка синхронизации"
        case .shoplistAddedNewItem:
            return "Товар уже есть в списке"
        case .productIsNotFound:
            return "Товар не найден в базе данных"
        case .other:
            return "Что-то пошло не так"
        }
    }
}

class DataProvider {
    enum SyncSteps: Int {
        case
        login,
        loadShoplist,
        needSync,
        categories,
        uoms,
        products,
        statistic,
        putBackShoplist
        
        case total
        
        var text: String {
            let start = "Загружаем"
            switch self {
            case .login:
                return "Подсоединяемся к базе"
            case .needSync:
                return "Начинаем синхронизацию"
            case .categories:
                return "\(start) категории"
            case .uoms:
                return "\(start) единицы измерения"
            case .products:
                return "\(start) товары"
            case .statistic:
                return "\(start) актуальные цены"
            case .loadShoplist, .putBackShoplist:
                return "\(start) ваш шоплист"
            default: return "Все готово к работе !!!"
            }
        }
    }
    
    var maxSyncSteps: Int {
        return SyncSteps.total.rawValue
    }
    
    // MARK: update events
    var onUpdateShoplist: ActionClousure?
    var onSyncProgress: ((Int, Int, String) -> Void)?
    var onSyncNext: (() -> Void)?
    var currentNext: Int = 0

    var sections = [String]()
    var shoplist: [DPShoplistItemModel] = [] {
        didSet {
            DispatchQueue.main.async {
                self.onUpdateShoplist?()
            }
        }
    }

    var total: Double {
        let sum = shoplist.reduce(0) { $0 + ($1.productPrice * $1.quantity) }
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

    public func syncCloud(completion: @escaping (ResultType<Bool, DataProviderError>)->Void) {
        firebaseLogin(completion: completion)
        self.onSyncNext = { [weak self] in
            
            guard let `self` = self else { return  }
            self.currentNext += 1
            guard let type = SyncSteps(rawValue: self.currentNext) else { return  }
            self.onSyncProgress?(self.currentNext, self.maxSyncSteps, type.text)
            
            switch type {
            case .needSync:
                if !self.needToSync() {
                    self.currentNext = SyncSteps.statistic.rawValue
                    completion(ResultType.success(true))
                }
                self.onSyncNext?()
            case .categories:
                self.syncCategories(completion: completion)
            case .uoms:
                self.syncUom(completion: completion)
            case .products:
                self.syncProducts(completion: completion)
            case .statistic:
                self.syncStatistics(completion: completion)
            case .loadShoplist:
                self.loadShoplist(completion: completion)
            case .putBackShoplist:
                self.saveShoplist()
                self.onSyncNext?()
            case .total: break
            case .login: break
            }
        }
    }
    
    func firebaseLogin(completion: @escaping (ResultType<Bool, DataProviderError>)->Void) {
        FirebaseService.data.loginToFirebase(completion: { result in
            switch result {
            case .success:
                print("Firebase login success")
                self.onSyncNext?()
            case let .failure(error):
                completion(self.syncHandle(error: error))
                return
            }
        })
    }
    
    func loadShoplist(completion: @escaping (ResultType<Bool, DataProviderError>)->Void) {
        let outletId: String? = nil
        guard let shp = CoreDataService.data.loadShopList(for: outletId) else {
            completion(ResultType.failure(DataProviderError.syncError("Что-то пошло не так")))
            return
        }
        self.shoplist = shp
        print("Function: \(#function), line: \(#line)")
        self.onSyncNext?()
    }

    func syncHandle(error: Error) -> ResultType<Bool, DataProviderError> {
        UserDefaults.standard.set(0, forKey: "LaunchedTime")
        return ResultType.failure(DataProviderError
            .syncError("Синхронизация не удалась: \(error.localizedDescription) "))
    }

    func needToSync() -> Bool {
//        return true
        
        var times = UserDefaults.standard.integer(forKey: "LaunchedTime")
        switch times {
        case 0:
            times += 1
            UserDefaults.standard.set(times, forKey: "LaunchedTime")
            return true
        case 10:
            times = 1
            UserDefaults.standard.set(times, forKey: "LaunchedTime")
            return true
        default:
            times += 1
            UserDefaults.standard.set(times, forKey: "LaunchedTime")
            return false
        }
    }

    private func saveShoplist() {
        for item in shoplist {
            CoreDataService.data.saveToShopList(item)
        }
        shoplist.removeAll()
    }

    private func syncCategories(completion: @escaping (ResultType<Bool, DataProviderError>)->Void) {
        CoreDataService.data.syncCategories { [weak self] result in
            guard let `self` = self else {
                fatalError()
            }
            
            switch result {
            case .success:
                self.onSyncNext?()
                print("Function: \(#function), line: \(#line)")
            case let .failure(error):
                completion(ResultType.failure(DataProviderError.syncError(error.localizedDescription)))
            }
        }
    }

    private func syncProducts(completion: @escaping (ResultType<Bool, DataProviderError>)->Void) {
        CoreDataService.data.syncProducts { [weak self] result in // get from firebase
            guard let `self` = self else {
                fatalError()
            }
            switch result {
            case .success:
                self.onSyncNext?()
                print("Function: \(#function), line: \(#line)")
                
            case let .failure(error):
                completion(ResultType.failure(.syncError(error.localizedDescription)))
            }
        }
    }

    private func syncStatistics(completion: @escaping (ResultType<Bool, DataProviderError>)->Void) {
        CoreDataService.data.syncStatistics { [weak self] result in // get from firebase
            guard let `self` = self else {
                fatalError()
            }
            switch result {
            case .success:
                self.onSyncNext?()
                print("Function: \(#function), line: \(#line)")
                completion(ResultType.success(true))
            case let .failure(error):
                completion(ResultType.failure(.syncError(error.localizedDescription)))
            }
        }
    }

    private func syncUom(completion: @escaping (ResultType<Bool, DataProviderError>)->Void) {
        CoreDataService.data.syncUoms { [weak self] result in // get from firebase
            guard let `self` = self else {
                fatalError()
            }
            switch result {
            case .success:
                self.onSyncNext?()
                 print("Function: \(#function), line: \(#line)")
            case let .failure(error):
                completion(ResultType.failure(.syncError(error.localizedDescription)))
            }
        }
    }


    func getQuantityOfProducts() -> Int {
        
        return CoreDataService.data.getQuantityOfProducts()
        
    }
    
    
    
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

    func update(_ product: DPUpdateProductModel) {
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

        if let _ = shoplist.index(of: item) {
            print("\(item.productName) already in shoplist")
            return ResultType.failure(DataProviderError.shoplistAddedNewItem("Уже в списке"))
        }

        shoplist.append(item)
        addSection(for: item)
        CoreDataService.data.saveToShopList(item)

        return ResultType.success(true)
    }

    func getShopItems(with pageOffset: Int, for outletId: String) -> [DPProductModel]? {
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

//    func change(_ changedItem: DPShoplistItemModel) -> Bool {
//        if let index = shoplist.index(of: changedItem) {
//            shoplist[index] = changedItem
//            return true
//        }
//        return false
//    }

    func changeShoplistItem(_ quantity: Double, for productId: String) {
        for (index, item) in shoplist.enumerated() {
            if item.productId == productId {
               shoplist[index].quantity = quantity
            }
        }
        CoreDataService.data.changeShoplistItem(quantity, for: productId)
    }

    func getItem(index: IndexPath) -> DPShoplistItemModel? {
        let sec = index.section
        let indexInSec = index.row

        var productListInsection: [DPShoplistItemModel] = []
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
    
    
    func getQuantity(for productId: String) -> Double? {
       let p = shoplist.filter { item in
            item.productId == productId
        }
        return p.first?.quantity
    }

    func getItem(with barcode: String, and outletId: String) -> DPProductModel? {
        guard let cdModel = CoreDataService.data.getItem(by: barcode, and: outletId) else {
            return nil
        }

//        guard let uom: Uom = CoreDataService.data.getUom(by: cdModel.uomId) else {
//            fatalError("Uom is not found in CoreData")
//        }

        //let isPerPiece = uom.iterator.truncatingRemainder(dividingBy: 1) == 0

        return DPProductModel(id: cdModel.id,
                              name: cdModel.name,
                              categoryId: cdModel.categoryId,
                              uomId: cdModel.uomId)

    }

    func getCategoryList() -> [DPCategoryModel]? {
        guard let cdModelList = CoreDataService.data.getCategories() else {
            fatalError("category list is empty")
        }
        return CategoryMapper.transform(from: cdModelList)
    }

    func mapper(from cdModel: CDCategoryModel) -> DPCategoryModel {
        return DPCategoryModel(id: cdModel.id, name: cdModel.name)
    }

    func getUomList() -> [UomModelView]? {
        guard let uoms = CoreDataService.data.getUomList() else {
            return nil
        }
        return CoreDataParsers.parse(from: uoms)
    }

    func getUomName(for id: Int32) -> String? {
        guard
        let uom = CoreDataService.data.getUom(by: id),
        let uomName = uom.uom
        else {
            fatalError("Uom is not available")
        }
        
        return uomName
    }
    
    func getUom(for id: Int32) -> UomModelView? {
        guard
            let uom = CoreDataService.data.getUom(by: id) else {
             fatalError("Uom is not available")
                
        }
        return CoreDataParsers.parse(from: uom)
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
        guard let list =  CoreDataService.data.loadShopList(for: outletId) else {
            return
        }
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
        let count = shoplist.reduce(0) { (result, item) in
            result + (item.productCategory == sections[section] ? 1 : 0)
        }
        return count
    }

    var sectionCount: Int {
        return sections.count
    }

    func headerString(for section: Int) -> String {
        guard !sections.isEmpty else {
            return "No section"
        }
        
        return sections[section]
    }
}

extension DataProvider {

    func getPrice(for productId: String, and outletId: String) -> Double {
        return CoreDataService.data.getPrice(for: productId, and: outletId)
    }

    func getMinPrice(for productId: String, and outletId: String) -> Double {
        return CoreDataService.data.getMinPrice(for: productId, and: outletId)

    }

}
