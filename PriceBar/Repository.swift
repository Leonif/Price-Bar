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

enum RepositoryError: Error {
    case syncError(String)
    case shoplistAddedNewItem(String)
    case productIsNotFound(String)
    case statisticError(String)
    case other(String)

    var message: String {
        switch self {
        case .syncError:
            return R.string.localizable.error_sync_stopped()
        case .shoplistAddedNewItem:
            return R.string.localizable.common_already_in_list()
        case .productIsNotFound:
            return R.string.localizable.error_product_is_not_found()
        case .other:
            return R.string.localizable.error_something_went_wrong()
        case .statisticError:
            return R.string.localizable.error_no_statistics()
        }
    }
}

class Repository {
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
            let start = R.string.localizable.common_loading()
            switch self {
            case .login:
                return R.string.localizable.sync_process_connecting()
            case .needSync:
                return R.string.localizable.sync_process_start()
            case .categories:
                return R.string.localizable.sync_process_categories(start)
            case .uoms:
                return R.string.localizable.sync_process_uom(start)
            case .products:
                return R.string.localizable.sync_process_products(start)
            case .statistic:
                return R.string.localizable.sync_process_prices(start)
            case .loadShoplist, .putBackShoplist:
                return R.string.localizable.sync_process_shoplist(start)
            default: return R.string.localizable.sync_process_all_is_done()
            }
        }
    }
    
    var maxSyncSteps: Int {
        return SyncSteps.total.rawValue
    }
    
    // MARK: update events
    var onSyncProgress: ((Int, Int, String) -> Void)?
    var onSyncNext: (() -> Void)?
    var currentNext: Int = 0

    var shoplist: [ShoplistItem] = []
    
    var itemsCount: Int {
        return shoplist.count
    }
    
    var total: Double {
        let sum = shoplist.reduce(0) { $0 + ($1.productPrice * $1.quantity) }
        return sum
    }

//    var defaultCategory: DPCategoryModel? {
//        guard let cd = CoreDataService.data.defaultCategory else {
//            return nil
//        }
//        return DPCategoryModel(id: cd.id, name: cd.name)
//    }
//
//    var defaultUom: DPUomModel? {
//        guard let cd = CoreDataService.data.defaultUom else {
//            return nil
//        }
//        return DPUomModel(id: cd.id, name: cd.name)
//    }

    public func syncCloud(completion: @escaping (ResultType<Bool, RepositoryError>)->Void) {
        defer {  self.currentNext = 0  }
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
                self.onSyncNext?()
//                self.loadShoplist(completion: completion)
            case .putBackShoplist:
                self.saveShoplist()
                self.onSyncNext?()
            case .total: break
            case .login: break
            }
        }
    }
    
    func firebaseLogin(completion: @escaping (ResultType<Bool, RepositoryError>)->Void) {
        FirebaseService.data.loginToFirebase(completion: { result in
            switch result {
            case .success:
                debugPrint("Firebase login success")
                self.onSyncNext?()
            case let .failure(error):
                completion(self.syncHandle(error: error))
                return
            }
        })
    }

    func syncHandle(error: Error) -> ResultType<Bool, RepositoryError> {
        UserDefaults.standard.set(0, forKey: "LaunchedTime")
        return ResultType.failure(RepositoryError
            .syncError("\(R.string.localizable.error_sync_stopped()) \(error.localizedDescription) "))
    }

    func needToSync() -> Bool {
        return false
    }

    private func saveShoplist() {
        for item in shoplist {
            CoreDataService.data.saveToShopList(item)
        }
        shoplist.removeAll()
    }

    private func syncCategories(completion: @escaping (ResultType<Bool, RepositoryError>)->Void) {
        CoreDataService.data.syncCategories { [weak self] result in
            guard let `self` = self else {
                fatalError()
            }
            
            switch result {
            case .success:
                self.onSyncNext?()
            case let .failure(error):
                completion(ResultType.failure(RepositoryError.syncError(error.localizedDescription)))
            }
        }
    }

    private func syncProducts(completion: @escaping (ResultType<Bool, RepositoryError>)->Void) {
        CoreDataService.data.syncProducts { [weak self] result in // get from firebase
            guard let `self` = self else {
                fatalError()
            }
            switch result {
            case .success:
                self.onSyncNext?()
            case let .failure(error):
                completion(ResultType.failure(.syncError(error.localizedDescription)))
            }
        }
    }

    private func syncStatistics(completion: @escaping (ResultType<Bool, RepositoryError>)->Void) {
        CoreDataService.data.syncStatistics { [weak self] result in // get from firebase
            guard let `self` = self else {
                fatalError()
            }
            switch result {
            case .success:
        self.onSyncNext?()
        completion(ResultType.success(true))
            case let .failure(error):
                completion(ResultType.failure(.syncError(error.localizedDescription)))
            }
        }
    }

    private func syncUom(completion: @escaping (ResultType<Bool, RepositoryError>)->Void) {
        CoreDataService.data.syncUoms { [weak self] result in // get from firebase
            guard let `self` = self else {
                fatalError()
            }
            switch result {
            case .success:
                self.onSyncNext?()
            case let .failure(error):
                completion(ResultType.failure(.syncError(error.localizedDescription)))
            }
        }
    }


    func getQuantityOfProducts() -> Int {
        return CoreDataService.data.getQuantityOfProducts()
        
    }
    
    
    
    func save(new statistic: DPPriceStatisticModel) {
        let fb = FBItemStatistic(productId: statistic.productId,
                               price: statistic.newPrice,
                               outletId: statistic.outletId)
        FirebaseService.data.save(new: fb)
    }

    func save(new product: DPUpdateProductModel) {
        let fb = FBProductModel(id: product.id,
                                name: product.name,
                                brand: product.brand,
                                weightPerPiece: product.weightPerPiece,
                                categoryId: product.categoryId,
                                uomId: product.uomId)
        FirebaseService.data.saveOrUpdate(fb)
    }

    func update(_ product: DPUpdateProductModel) {
        let pr = CDProductModel(id: product.id,
                                name: product.name,
                                brand: product.brand,
                                weightPerPiece: product.weightPerPiece,
                              categoryId: product.categoryId,
                              uomId: product.uomId)

        CoreDataService.data.update(pr)

        let fb = FBProductModel(id: product.id,
                                name: product.name,
                                brand: product.brand,
                                weightPerPiece: product.weightPerPiece,
                                categoryId: product.categoryId,
                                uomId: product.uomId)
        FirebaseService.data.saveOrUpdate(fb)
    }

    func saveToShopList(new item: ShoplistItem) -> ResultType<Bool, RepositoryError> {

        if let _ = shoplist.index(of: item) {
            return ResultType.failure(RepositoryError.shoplistAddedNewItem(R.string.localizable.common_already_in_list()))
        }
        shoplist.append(item)
        CoreDataService.data.saveToShopList(item)

        return ResultType.success(true)
    }
    
   ////////////////////////////// FIXME /////////////////////////////////
    func getShopItems(with pageOffset: Int, limit: Int, for outletId: String, completion: @escaping (ResultType<[DPProductEntity], RepositoryError>) -> Void) {
        FirebaseService.data.getProductList(with: pageOffset, limit: limit) { (result) in
            switch result {
            case let .success(products):
                let dpProducts = products.map { ProductMapper.mapper(from: $0) }
                completion(ResultType.success(dpProducts))
            case let .failure(error):
                completion(ResultType.failure(RepositoryError.other(error.localizedDescription)))
            }
        }
        
        
    }
    
    func getPricesFor(outletId: String, completion: @escaping ([ProductPrice]) -> Void) {
        FirebaseService.data.getPrices(for: outletId, callback: { (statistics) in
            let prices = statistics.map {
                return ProductPrice(productId: $0.productId,
                                    currentPrice: $0.price,
                                    outletId: $0.outletId,
                                    date: $0.date)
            }
            completion(prices)
        })
    }
    
    func getPricesFor(productId: String, completion: @escaping ([ProductPrice]) -> Void) {
        
        FirebaseService.data.getPricesFor(productId) { (statistics) in
            let prices = statistics.map {
                return ProductPrice(productId: $0.productId,
                                    currentPrice: $0.price,
                                    outletId: $0.outletId,
                                    date: $0.date)
            }
            completion(prices)
        }
    }
    
    func getPrice(for productId: String, and outletId: String, callback: @escaping (Double) -> Void) {
        self.getPriceFromCloud(for: productId, and: outletId) { (price) in
            guard let price = price else {
                callback(0)
                return
            }
            callback(price)
        }
    }
    
    private func getPriceFromCloud(for productId: String, and outletId: String, callback: @escaping (Double?) -> Void) {
        
        FirebaseService.data.getPrice(with: productId, outletId: outletId) { (price) in
            callback(price)
        }
        
    }
    
    // FIXME: get price just cloud
//    func getPricesStatisticByOutlet(for productId: String) -> [DPPriceStatisticModel] {
//        let object = CoreDataService.data.getPricesStatisticByOutlet(for: productId)
//        return object.map { StatisticMapper.mapper(from: $0) }
//    }
    
    

    func filterItemList(contains text: String, for outletId: String, completion: @escaping (ResultType<[DPProductEntity], RepositoryError>) -> Void)  {

        FirebaseService.data.getFiltredProductList(with: text) { (result) in
            switch result {
            case let .success(products):
                let dpProducts = products.map { ProductMapper.mapper(from: $0) }
                completion(ResultType.success(dpProducts))
            case let .failure(error):
                completion(ResultType.failure(RepositoryError.other(error.localizedDescription)))
            }
        }
    }

    
    func remove(itemId: String) {
        self.shoplist = self.shoplist.filter { $0.productId != itemId }

        CoreDataService.data.removeFromShopList(with: itemId)
    }

    func clearShoplist() {
        shoplist.removeAll()
        CoreDataService.data.removeAll(from: "ShopList")

    }

    
//    func getUomName(for productId: String) -> String {
//        let product = CoreDataService.data.getProduct(by: productId)
//        
//        return product!.toUom!.uom!
//    }
    
    
    func getProductName(for productId: String, completion: @escaping (ResultType<String?, RepositoryError>)-> Void) {
        FirebaseService.data.getProduct(with: productId) { (fbProductEntity) in
            completion(ResultType.success(fbProductEntity?.fullName))
        }
    }
    
    
    func getProductEntity(for productId: String, completion: @escaping (ResultType<DPProductEntity, RepositoryError>)-> Void) {
        FirebaseService.data.getProduct(with: productId) { (fbProductEntity) in
            
            guard let fbProductEntity = fbProductEntity else {
                completion(ResultType.failure(RepositoryError.other(R.string.localizable.error_something_went_wrong())))
            }
            
            
            completion(ResultType.success(DPProductEntity(id: productId,
                                                          name: fbProductEntity.name,
                                                          brand: fbProductEntity.brand,
                                                          weightPerPiece: fbProductEntity.weightPerPiece,
                                                          categoryId: fbProductEntity.categoryId,
                                                          uomId: fbProductEntity.uomId)))
        }
    }
    
    

    func getCategoryList(completion: @escaping (ResultType<[DPCategoryViewEntity]?, RepositoryError>) -> Void)  {
        FirebaseService.data.getCategoryList { (result) in
            switch result {
            case let .success(categoryList):
                guard let categoryList = categoryList else {
                    completion (ResultType.success(nil))
                    return
                }
                
                let c: [DPCategoryViewEntity] = categoryList.map { DPCategoryViewEntity(id: $0.id, name: $0.name) }
                completion(ResultType.success(c))

            case let .failure(error):
                completion(ResultType.failure(.other(error.localizedDescription)))
            }
        }
    }
    
    
    
    func getUomList(completion: @escaping (ResultType<[UomModelView]?, RepositoryError>) -> Void)  {
        
        FirebaseService.data.getUomList { (result) in
            switch result {
            case let .success(uomList):
                guard let uomList = uomList else {
                    completion (ResultType.success(nil))
                    return
                }
                
                let c: [UomModelView] = uomList.map { UomMapper.mapper(from: $0)  }
                completion(ResultType.success(c))
                
            case let .failure(error):
                completion(ResultType.failure(.other(error.localizedDescription)))
            }
        }

        
        
        
    }
    
    
    
    func getCategoryId(for categoryName: String, completion: @escaping (ResultType<Int?, RepositoryError>) -> Void) {
        FirebaseService.data.getCategoryId(for: categoryName) { (result) in
            switch result {
            case let .success(categoryId):
                completion(ResultType.success(categoryId))
            case let .failure(error):
                completion(ResultType.failure(.other(error.localizedDescription)))
            }
        }
    }
    
    
    
    func getUomId(for uomName: String, completion: @escaping (ResultType<Int?, RepositoryError>) -> Void) {
        FirebaseService.data.getUomId(for: uomName) { (result) in
            switch result {
            case let .success(uomId):
                completion(ResultType.success(uomId))
            case let .failure(error):
                completion(ResultType.failure(.other(error.localizedDescription)))
            }
        }
    }
    
    func getUomName(for uomId: Int32, completion: @escaping (ResultType<String?, RepositoryError>) -> Void) {
        FirebaseService.data.getUomName(for: uomId) { (result) in
            switch result {
            case let .success(uomName):
                completion(ResultType.success(uomName))
            case let .failure(error):
                completion(ResultType.failure(.other(error.localizedDescription)))
            }
        }
    }
    
    
    func getCategoryName(for categoryId: Int32, completion: @escaping (ResultType<String?, RepositoryError>) -> Void) {
        FirebaseService.data.getCategoryName(for: categoryId) { (result) in
            switch result {
            case let .success(categoryName):
                completion(ResultType.success(categoryName))
            case let .failure(error):
                completion(ResultType.failure(.other(error.localizedDescription)))
            }
        }
    }
    


    func mapper(from cdModel: CDCategoryModel) -> DPCategoryViewEntity {
        return DPCategoryViewEntity(id: cdModel.id, name: cdModel.name)
    }

    

//    func getUomName(for id: Int32) -> String? {
//        guard
//        let uom = CoreDataService.data.getUom(by: id),
//        let uomName = uom.uom
//        else {
//            fatalError("Uom is not available")
//        }
//
//        return uomName
//    }
    
//    func getUom(for id: Int32) -> UomModelView? {
//        guard
//            let uom = CoreDataService.data.getUom(by: id) else {
//             fatalError("Uom is not available")
//                
//        }
//        return CoreDataParsers.parse(from: uom)
//    }

//    func getCategoryName(category id: Int32) -> String? {
//        guard let category = CoreDataService.data.getCategory(by: id),
//            let categoryName = category.category else {
//            return nil
//        }
//        return categoryName
//    }

    func loadShopList() -> [ShoplistItem]?  {
        shoplist.removeAll()
        guard let list = CoreDataService.data.loadShopList() else {
            return nil
        }
        
        let shoplistWithoutPrices: [ShoplistItem] = list.map { item in
            ShoplistItem(productId: item.productId,
                         productName: item.productName,
                         brand: item.brand,
                         weightPerPiece: item.weightPerPiece,
                         categoryId: item.categoryId,
                         productCategory: item.productCategory,
                         productPrice: 0.0,
                         uomId: item.uomId,
                         productUom: item.productUom,
                         quantity: item.quantity,
                         checked: item.checked,
                         parameters: item.parameters) }
        
        
        self.shoplist = shoplistWithoutPrices
        return shoplistWithoutPrices
    }
}




extension Repository {
    func getItem(with barcode: String, and outletId: String, callback: @escaping (DPProductEntity?) -> Void) {
            self.getProductFromCloud(with: barcode) { (item) in
                guard let item = item else {
                    callback(nil)
                    return
                }
                let result = DPProductEntity(id: item.id,
                                            name: item.name,
                                            brand: item.brand,
                                            weightPerPiece: item.weightPerPiece,
                                            categoryId: item.categoryId,
                                            uomId: item.uomId)
                callback(result)
            }
        
    }
    
    
    private func getProductFromCloud(with productId: String, callback: @escaping (FBProductModel?) -> Void) {
        FirebaseService.data.getProduct(with: productId) { (item) in
            callback(item)
        }
    }
}
