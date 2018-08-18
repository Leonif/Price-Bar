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

enum ProductModelError: Error {
    case syncError(String)
    case alreadyAdded(String)
    case productIsNotFound(String)
    case statisticError(String)
    case other(String)

    var errorDescription: String {
        switch self {
        case .syncError:
            return R.string.localizable.error_sync_stopped()
        case .alreadyAdded:
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

class ProductModel {
    // MARK: update events
    var onSyncProgress: ((Int, Int, String) -> Void)?
    var onSyncNext: (() -> Void)?
    var currentNext: Int = 0

    func firebaseLogin(completion: @escaping (ResultType<Bool, ProductModelError>)->Void) {
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

    func getQuantityOfProducts(completion: @escaping (ResultType<Int, ProductModelError>) -> Void) {
        FirebaseService.data.getProductCount { (result) in
            switch result {
            case let .success(count):
                completion(ResultType.success(count))
            case let .failure(error):
                completion(ResultType.failure(ProductModelError.other(error.localizedDescription)))
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

    func saveToShopList(new item: ShoplistItem, completion: @escaping (ResultType<Bool, ProductModelError>) -> Void) {
        guard let shoplist = CoreDataService.data.loadShopList() else { fatalError() }
        if shoplist.contains(where: { $0.productId == item.productId }) {
            completion(ResultType.failure(ProductModelError.alreadyAdded(R.string.localizable.common_already_in_list())))
            return
        }
        CoreDataService.data.saveToShopList(CDShoplistItem(productId: item.productId, quantity: item.quantity))
        completion(ResultType.success(true))
    }
    
    func changeShoplistItem( _ quantity: Double, for productId: String) {
        CoreDataService.data.changeShoplistItem(quantity, for: productId)
    }
    
   ////////////////////////////// FIXME /////////////////////////////////
    func getShopItems(with pageOffset: Int, limit: Int, for outletId: String, completion: @escaping (ResultType<[DPProductEntity], ProductModelError>) -> Void) {
        FirebaseService.data.getProductList(with: pageOffset, limit: limit) { (result) in
            switch result {
            case let .success(products):
                let dpProducts = products.map { ProductMapper.transformToDPProductEntity(from: $0) }
                completion(ResultType.success(dpProducts))
            case let .failure(error):
                completion(ResultType.failure(ProductModelError.other(error.localizedDescription)))
            }
        }
    }
    
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
    
    
    func getCountry(for productId: String, completion: @escaping (String?) -> Void) {
        self.getCountryFromCloud(for: productId) { (country) in
            guard let country = country else {
                completion(nil)
                return
            }
            completion(country)
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
    
    private func getCountryFromCloud(for productId: String, completion: @escaping (String?) -> Void) {
        FirebaseService.data.getCountry(for: productId) { (country) in
            completion(country)
        }
    }
    
    

    func filterItemList(contains text: String, for outletId: String, completion: @escaping (ResultType<[DPProductEntity], ProductModelError>) -> Void)  {
        FirebaseService.data.getFiltredProductList(with: text) { (result) in
            switch result {
            case let .success(products):
                let dpProducts = products.map { ProductMapper.transformToDPProductEntity(from: $0) }
                completion(ResultType.success(dpProducts))
            case let .failure(error):
                completion(ResultType.failure(ProductModelError.other(error.localizedDescription)))
            }
        }
    }
    
    func remove(itemId: String) {
        CoreDataService.data.removeFromShopList(with: itemId)
    }

    func clearShoplist() {
        CoreDataService.data.removeAll(from: "ShopList")
    }
    
    
    func getProductName(for productId: String, completion: @escaping (ResultType<String?, ProductModelError>)-> Void) {
        FirebaseService.data.getProduct(with: productId) { (fbProductEntity) in
            completion(ResultType.success(fbProductEntity?.fullName))
        }
    }
    
    func getProductEntity(for productId: String, completion: @escaping (ResultType<DPProductEntity, ProductModelError>)-> Void) {
        FirebaseService.data.getProduct(with: productId) { (fbProductEntity) in
            
            guard let fbProductEntity = fbProductEntity else {
                completion(ResultType.failure(ProductModelError.other(R.string.localizable.error_something_went_wrong())))
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

    func getCategoryList(completion: @escaping (ResultType<[DPCategoryViewEntity]?, ProductModelError>) -> Void)  {
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
    
    func getUomList(completion: @escaping (ResultType<[UomModelView]?, ProductModelError>) -> Void)  {
        
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
    
    
    
    func getCategoryId(for categoryName: String, completion: @escaping (ResultType<Int?, ProductModelError>) -> Void) {
        FirebaseService.data.getCategoryId(for: categoryName) { (result) in
            switch result {
            case let .success(categoryId):
                completion(ResultType.success(categoryId))
            case let .failure(error):
                completion(ResultType.failure(.other(error.localizedDescription)))
            }
        }
    }
    
    func getUomId(for uomName: String, completion: @escaping (ResultType<Int?, ProductModelError>) -> Void) {
        FirebaseService.data.getUomId(for: uomName) { (result) in
            switch result {
            case let .success(uomId):
                completion(ResultType.success(uomId))
            case let .failure(error):
                completion(ResultType.failure(.other(error.localizedDescription)))
            }
        }
    }
    
    func getUomName(for uomId: Int32, completion: @escaping (ResultType<String?, ProductModelError>) -> Void) {
        FirebaseService.data.getUomName(for: uomId) { (result) in
            switch result {
            case let .success(uomName):
                completion(ResultType.success(uomName))
            case let .failure(error):
                completion(ResultType.failure(.other(error.localizedDescription)))
            }
        }
    }
    
    func getCategoryName(for categoryId: Int32, completion: @escaping (ResultType<String?, ProductModelError>) -> Void) {
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

    func loadShopList(for outletId: String?, completion: @escaping ([ShoplistItem]) -> Void)  {
        guard let savedShoplistWithoutPrices = CoreDataService.data.loadShopList() else {
            return
        }
        var shoplistWithPrices: [ShoplistItem] = []
        let shopItemGroup = DispatchGroup()
        let shopItemsWithPricesGroup = DispatchGroup()
        
        for item in savedShoplistWithoutPrices {
            var shopListItem = ShoplistItem()
            shopItemsWithPricesGroup.enter()
            shopItemGroup.enter()
            self.getProductInfo(for: item) { (shopItem, error)  in
                shopListItem.productId = shopItem?.productId ?? ""
                shopListItem.country = shopItem?.country ?? ""
                shopListItem.productName = shopItem?.productName ?? ""
                shopListItem.brand = shopItem?.brand ?? ""
                shopListItem.weightPerPiece = shopItem?.weightPerPiece ?? ""
                shopListItem.categoryId = shopItem?.categoryId ?? -1
                shopListItem.productCategory = shopItem?.productCategory ?? ""
                //                shopListItem.productPrice = productPrice
                shopListItem.uomId = shopItem?.uomId ?? -1
                shopListItem.productUom = shopItem?.productUom ?? ""
                //                shopListItem.quantity = quantity
                shopListItem.parameters = shopItem?.parameters ?? []
                shopItemGroup.leave()
            }
            if let outletId = outletId {
                shopItemGroup.enter()
                self.getPrice(for: item.productId, and: outletId, completion: { (price) in
                    shopListItem.productPrice = price
                    shopItemGroup.leave()
                })
            } else {
                shopListItem.productPrice = 0.0
                shopItemGroup.leave()
            }
            shopItemGroup.notify(queue: .main) {
                shopListItem.quantity = item.quantity
                shoplistWithPrices.append(shopListItem)
                shopItemsWithPricesGroup.leave()
            }
        }
        shopItemsWithPricesGroup.notify(queue: .main) {
            completion(shoplistWithPrices)
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
        var shopListItem = ShoplistItem()
        
        self.getProductEntity(for: item.productId) { [weak self] (result) in
            guard let `self` = self else { return }
            switch result {
            case let .success(productEntity):
                shopListItem.productId = productEntity.id
                shopListItem.productName =  productEntity.name
                shopListItem.brand = productEntity.brand
                shopListItem.weightPerPiece = productEntity.weightPerPiece
                shopListItem.categoryId = productEntity.categoryId
                shopListItem.uomId = productEntity.uomId
                
                let additionaInfoGroup = DispatchGroup()
                additionaInfoGroup.enter()
                self.getParametredUom(for: productEntity.uomId, completion: { (parametredUom) in
                    shopListItem.productUom = parametredUom.name
                    shopListItem.parameters = parametredUom.parameters
                    additionaInfoGroup.leave()
                })
                
                additionaInfoGroup.enter()
                self.getCategoryName(for: productEntity.categoryId, completion: { (result) in
                    switch result {
                    case let .success(categoryName):
                        shopListItem.productCategory = categoryName ?? "No category"
                        additionaInfoGroup.leave()
                    case let .failure(error):
                        completion(nil, error)
                    }
                })
                
                additionaInfoGroup.notify(queue: .main) {
                    completion(shopListItem, nil)
                }
                
            case let .failure(error):
                completion(nil, error)
            }
        }
    }
}




extension ProductModel {
    func getItem(with barcode: String, callback: @escaping (DPProductEntity?) -> Void) {
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
