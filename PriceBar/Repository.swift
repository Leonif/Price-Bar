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
//    enum SyncSteps: Int {
//        case
//        login,
//        loadShoplist,
//        needSync,
//        categories,
//        uoms,
//        products,
//        statistic,
//        putBackShoplist
//
//        case total
//
//        var text: String {
//            let start = R.string.localizable.common_loading()
//            switch self {
//            case .login:
//                return R.string.localizable.sync_process_connecting()
//            case .needSync:
//                return R.string.localizable.sync_process_start()
//            case .categories:
//                return R.string.localizable.sync_process_categories(start)
//            case .uoms:
//                return R.string.localizable.sync_process_uom(start)
//            case .products:
//                return R.string.localizable.sync_process_products(start)
//            case .statistic:
//                return R.string.localizable.sync_process_prices(start)
//            case .loadShoplist, .putBackShoplist:
//                return R.string.localizable.sync_process_shoplist(start)
//            default: return R.string.localizable.sync_process_all_is_done()
//            }
//        }
//    }
    
//    var maxSyncSteps: Int {
//        return SyncSteps.total.rawValue
//    }
    
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

    
    func firebaseLogin(completion: @escaping (ResultType<Bool, RepositoryError>)->Void) {
        FirebaseService.data.loginToFirebase(completion: { result in
            switch result {
            case .success:
                debugPrint("Firebase login success")
                completion(ResultType.success(true))
            case let .failure(error):
                completion(ResultType.failure(.other(error.localizedDescription)))
                return
            }
        })
    }


    func getQuantityOfProducts(completion: @escaping (ResultType<Int, RepositoryError>) -> Void) {
        
        FirebaseService.data.getProductCount { (result) in
            switch result {
            case let .success(count):
                completion(ResultType.success(count))
            case let .failure(error):
                completion(ResultType.failure(RepositoryError.other(error.localizedDescription)))
            }
        }
    }
    
    
    
    func savePrice(for productId: String, statistic: DPPriceStatisticModel) {
        let fb = FBItemStatistic(productId: statistic.productId,
                               price: statistic.newPrice,
                               outletId: statistic.outletId)
        FirebaseService.data.savePrice(for: productId, statistic: fb)
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
        CoreDataService.data.saveToShopList(CDShoplistItem(productId: item.productId, quantity: item.quantity))

        return ResultType.success(true)
    }
    
    
    func changeShoplistItem( _ quantity: Double, for productId: String) {
        CoreDataService.data.changeShoplistItem(quantity, for: productId)
    }
    
    
    
   ////////////////////////////// FIXME /////////////////////////////////
    func getShopItems(with pageOffset: Int, limit: Int, for outletId: String, completion: @escaping (ResultType<[DPProductEntity], RepositoryError>) -> Void) {
        FirebaseService.data.getProductList(with: pageOffset, limit: limit) { (result) in
            switch result {
            case let .success(products):
                let dpProducts = products.map { ProductMapper.mapToDPProductEntity(from: $0) }
                completion(ResultType.success(dpProducts))
            case let .failure(error):
                completion(ResultType.failure(RepositoryError.other(error.localizedDescription)))
            }
        }
        
        
    }
    
//    func getPricesFor(outletId: String, completion: @escaping ([ProductPrice]) -> Void) {
//        FirebaseService.data.getPrices(for: outletId, callback: { (statistics) in
//            let prices = statistics.map {
//                return ProductPrice(productId: $0.productId, productName: "",
//                                    currentPrice: $0.price,
//                                    outletId: $0.outletId,
//                                    date: $0.date)
//            }
//            completion(prices)
//        })
//    }
    
    func getPricesFor(productId: String, completion: @escaping ([ProductPrice]) -> Void) {
        
        FirebaseService.data.getPricesFor(productId) { (statistics) in
            let prices = statistics.map {
                return ProductPrice(productId: productId, productName: "",
                                    currentPrice: $0.price,
                                    outletId: $0.outletId,
                                    date: $0.date)
            }
            completion(prices)
        }
    }
    
    func getPrice(for productId: String, and outletId: String, completion: @escaping (Double) -> Void) {
        self.getPriceFromCloud(for: productId, and: outletId) { (price) in
            guard let price = price else {
                completion(0)
                return
            }
            completion(price)
        }
    }
    
    
    func getProductQuantity(productId: String) -> Double {
        
        return CoreDataService.data.getQuantityOfProduct(productId: productId)
        
        
    }
    
    
    private func getPriceFromCloud(for productId: String, and outletId: String, completion: @escaping (Double?) -> Void) {
        
        FirebaseService.data.getPrice(with: productId, outletId: outletId) { (price) in
            completion(price)
        }
        
    }

    func filterItemList(contains text: String, for outletId: String, completion: @escaping (ResultType<[DPProductEntity], RepositoryError>) -> Void)  {
        FirebaseService.data.getFiltredProductList(with: text) { (result) in
            switch result {
            case let .success(products):
                let dpProducts = products.map { ProductMapper.mapToDPProductEntity(from: $0) }
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
    
    
    func getProductName(for productId: String, completion: @escaping (ResultType<String?, RepositoryError>)-> Void) {
        FirebaseService.data.getProduct(with: productId) { (fbProductEntity) in
            completion(ResultType.success(fbProductEntity?.fullName))
        }
    }
    
    
    func getProductEntity(for productId: String, completion: @escaping (ResultType<DPProductEntity, RepositoryError>)-> Void) {
        FirebaseService.data.getProduct(with: productId) { (fbProductEntity) in
            
            guard let fbProductEntity = fbProductEntity else {
                completion(ResultType.failure(RepositoryError.other(R.string.localizable.error_something_went_wrong())))
                return
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

    func loadShopList(completion: @escaping ([ShoplistItem]) -> Void)  {
        shoplist.removeAll()
        guard let savedShoplist = CoreDataService.data.loadShopList() else {
            return
        }
        
        var shoplistWithZeroPrices: [ShoplistItem] = []
        
        
        let shopItemGroup = DispatchGroup()
        
        for item in savedShoplist {
            shopItemGroup.enter()
            self.getProductInfo(for: item) { (shopItem, error)  in
                
                if error == nil {
                    shoplistWithZeroPrices.append(shopItem!)
                }
                shopItemGroup.leave()
            }
        }
        
        
        shopItemGroup.notify(queue: .main) {
            completion(shoplistWithZeroPrices)
        }
    }
    
    func getParametredUom(for uomId: Int32, completion: @escaping (FBUomModel) -> Void) {
        FirebaseService.data.getParametredUom(for: uomId, completion: { (result) in
            switch result {
            case let .success(parametredUom):
                
                completion(parametredUom)
                
            case let .failure(error):
                fatalError(error.localizedDescription)
            }
        })
    }
    
    private func getProductInfo(for item: CDShoplistItem, completion: @escaping (ShoplistItem?, Error?) -> Void) {
        
        self.getProductEntity(for: item.productId) { (result) in
            switch result {
            case let .success(productEntity):
                
                self.getParametredUom(for: productEntity.uomId, completion: { (parametredUom) in
                    self.getCategoryName(for: productEntity.categoryId, completion: { (result) in
                        switch result {
                        case let .success(categoryName):
                            guard let categoryName = categoryName else { fatalError()}
                            completion(ShoplistItem(productId: item.productId,
                                                    productName: productEntity.name,
                                                    brand: productEntity.brand,
                                                    weightPerPiece: productEntity.weightPerPiece,
                                                    categoryId: productEntity.categoryId,
                                                    productCategory: categoryName,
                                                    productPrice: 0.0,
                                                    uomId: productEntity.uomId,
                                                    productUom: parametredUom.name,
                                                    quantity: item.quantity,
                                                    parameters: parametredUom.parameters), nil)
                        case let .failure(error):
                            completion(nil, error)
                        }
                    })
                })
            case let .failure(error):
                fatalError(error.localizedDescription)
            }
        }
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
