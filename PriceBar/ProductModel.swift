//
//  DataProvider.swift
//  Price Bar
//
//  Created by Leonid Nifantyev on 6/4/17.
//  Copyright © 2017 LionLife. All rights reserved.
//

import Foundation
import UIKit


protocol ProductModel {
    func getProductDetail(productId: String, outletId: String, completion: @escaping (ResultType<ShoplistViewItem, ProductModelError>) -> Void)
    
    // FIXME: move to right place
    //func loadShopList2(for outletId: String?, completion: @escaping ([ShoplistViewItem]) -> Void)
    func getProductList(for ids: [String], completion: (([ProductEntity]) -> Void))
    
    func getQuantityOfProducts(completion: @escaping (ResultType<Int, ProductModelError>) -> Void)
    func getItem(with barcode: String, callback: @escaping (ProductEntity?) -> Void)
    
    func getPriceList(for ids: [String], and outletId: String, completion: @escaping ([String: Double]) -> Void)
    func getPrice(for productId: String, and outletId: String, completion: @escaping (Double) -> Void)
    func savePrice(for productId: String, statistic: PriceStatisticViewItem)
    
    func getProductEntity(for productId: String, completion: @escaping (ResultType<ProductEntity, ProductModelError>)-> Void)
    func save(new product: ProductEntity)
    func getParametredUom(for uomId: Int32, completion: @escaping (UomEntity) -> Void)
    
    
    func getCategoryId(for categoryName: String, completion: @escaping (ResultType<Int?, ProductModelError>) -> Void)
    func getCategoryName(for categoryId: Int32, completion: @escaping (ResultType<String?, ProductModelError>) -> Void)
    func getCategoryList(completion: @escaping (ResultType<[CategoryEntity]?, ProductModelError>) -> Void)

    func getUomId(for uomName: String, completion: @escaping (ResultType<Int?, ProductModelError>) -> Void)
    func getUomName(for uomId: Int32, completion: @escaping (ResultType<String?, ProductModelError>) -> Void)
    func getUomList(completion: @escaping (ResultType<[UomViewItem]?, ProductModelError>) -> Void)
}

class ProductModelImpl: ProductModel {
    
    func getProductList(for ids: [String], completion: (([ProductEntity]) -> Void)) {
        
        var productEntities: [ProductEntity] = []
        
        for id in ids {
            self.getProductEntity(for: id, completion: { result in
                switch result {
                case let .success(entity):
                    productEntities.append(entity)
                case let .failure(error):
                    fatalError(error.errorDescription)
                }
                
            })
        }
        completion(productEntities)
    }
    
    
    
    
    func getProductDetail(productId: String, outletId: String, completion: @escaping (ResultType<ShoplistViewItem, ProductModelError>) -> Void) {
        
        let productInfo = DispatchGroup()
        var productEntity: ProductEntity!
        var categoryName: String!
        var country: String!
        var parametredUom: UomEntity!
        var price: Double!
        
        productInfo.enter()
        self.getItem(with: productId, callback: { (entity) in
            productEntity = entity
            let otherProductInfoGroup = DispatchGroup()
            
            guard let entity = entity else { fatalError() }
            
            otherProductInfoGroup.enter()
            self.getCategoryName(for: entity.categoryId) { (result) in
                switch result {
                case let .success(name):
                    categoryName = name
                    otherProductInfoGroup.leave()
                case let .failure(error):
                    fatalError(error.errorDescription)
                }
            }
            
            otherProductInfoGroup.enter()
            self.getParametredUom(for: entity.uomId) { (entity) in
                parametredUom = entity
                otherProductInfoGroup.leave()
            }
            otherProductInfoGroup.notify(queue: .main) {
                productInfo.leave()
            }
        })
        
        productInfo.enter()
        self.getPrice(for: productId, and: outletId) { (value) in
            price = value
            productInfo.leave()
        }
        
        productInfo.enter()
        self.getCountry(for: productId) { (value) in
            country = value
            productInfo.leave()
        }
        
        productInfo.notify(queue: .main) {
            let newItem = ShoplistViewItem(productId: productEntity.id, country: country,
                                       productName: productEntity.name,
                                       brand: productEntity.brand,
                                       weightPerPiece: productEntity.weightPerPiece,
                                       categoryId: productEntity.categoryId,
                                       productCategory: categoryName,
                                       productPrice: price,
                                       uomId: productEntity.uomId,
                                       productUom: parametredUom.name,
                                       quantity: 1.0,
                                       parameters: parametredUom.parameters)
            
            completion(ResultType.success(newItem))
        }
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
    
    func savePrice(for productId: String, statistic: PriceStatisticViewItem) {
        let fb = PriceItemEntity(productId: statistic.productId,
                               price: statistic.newPrice,
                               outletId: statistic.outletId)
        FirebaseService.data.savePrice(for: productId, statistic: fb)
    }

    func save(new product: ProductEntity) {
        let fb = ProductEntity(id: product.id,
                                name: product.name,
                                brand: product.brand,
                                weightPerPiece: product.weightPerPiece,
                                categoryId: product.categoryId,
                                uomId: product.uomId)
        FirebaseService.data.saveOrUpdate(fb)
    }

    func update(_ product: ProductEntity) {
        let fb = ProductEntity(id: product.id,
                                name: product.name,
                                brand: product.brand,
                                weightPerPiece: product.weightPerPiece,
                                categoryId: product.categoryId,
                                uomId: product.uomId)
        FirebaseService.data.saveOrUpdate(fb)
    }
    
   ////////////////////////////// FIXME /////////////////////////////////
    func getShopItems(with pageOffset: Int, limit: Int, for outletId: String, completion: @escaping (ResultType<[ProductEntity], ProductModelError>) -> Void) {
        FirebaseService.data.getProductList(with: pageOffset, limit: limit) { (result) in
            switch result {
            case let .success(products):
                let dpProducts = products.map { ProductMapper.transform(input: $0) }
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
    
    func getPriceList(for ids: [String], and outletId: String, completion: @escaping ([String: Double]) -> Void) {
        var prices: [String: Double] = [:]
        for id in ids {
            self.getPrice(for: id, and: outletId) { (price) in
                prices[id] = price
            }
        }
        completion(prices)
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
    
    private func getPriceFromCloud(for productId: String, and outletId: String, completion: @escaping (Double?) -> Void) {
        FirebaseService.data.getLastPrice(with: productId, outletId: outletId) { (price) in
            completion(price)
        }
    }
    
    private func getCountryFromCloud(for productId: String, completion: @escaping (String?) -> Void) {
        FirebaseService.data.getCountry(for: productId) { (country) in
            completion(country)
        }
    }
    
    

    func filterItemList(contains text: String, for outletId: String, completion: @escaping (ResultType<[ProductEntity], ProductModelError>) -> Void)  {
        FirebaseService.data.getFiltredProductList(with: text) { (result) in
            switch result {
            case let .success(products):
                let dpProducts = products.map { ProductMapper.transform(input: $0) }
                completion(ResultType.success(dpProducts))
            case let .failure(error):
                completion(ResultType.failure(ProductModelError.other(error.localizedDescription)))
            }
        }
    }
    
    func getProductName(for productId: String, completion: @escaping (ResultType<String?, ProductModelError>)-> Void) {
        FirebaseService.data.getProduct(with: productId) { (fbProductEntity) in
            completion(ResultType.success(fbProductEntity?.fullName))
        }
    }
    
    func getProductEntity(for productId: String, completion: @escaping (ResultType<ProductEntity, ProductModelError>)-> Void) {
        FirebaseService.data.getProduct(with: productId) { (fbProductEntity) in
            
            guard let fbProductEntity = fbProductEntity else {
                completion(ResultType.failure(ProductModelError.other(R.string.localizable.error_something_went_wrong())))
                return
            }
            completion(ResultType.success(ProductEntity(id: productId,
                                                          name: fbProductEntity.name,
                                                          brand: fbProductEntity.brand,
                                                          weightPerPiece: fbProductEntity.weightPerPiece,
                                                          categoryId: fbProductEntity.categoryId,
                                                          uomId: fbProductEntity.uomId,
                                                          country: fbProductEntity.country)))
        }
    }

    func getCategoryList(completion: @escaping (ResultType<[CategoryEntity]?, ProductModelError>) -> Void)  {
        FirebaseService.data.getCategoryList { (result) in
            switch result {
            case let .success(categoryList):
                guard let categoryList = categoryList else {
                    completion (ResultType.success(nil))
                    return
                }
                
                let c: [CategoryEntity] = categoryList.map { CategoryEntity(id: $0.id, name: $0.name) }
                completion(ResultType.success(c))

            case let .failure(error):
                completion(ResultType.failure(.other(error.localizedDescription)))
            }
        }
    }
    
    func getUomList(completion: @escaping (ResultType<[UomViewItem]?, ProductModelError>) -> Void)  {
        FirebaseService.data.getUomList { (result) in
            switch result {
            case let .success(uomList):
                guard let uomList = uomList else {
                    completion (ResultType.success(nil))
                    return
                }
                let c: [UomViewItem] = uomList.map { UomMapper.transform(input: $0)  }
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

    
    
    func getParametredUom(for uomId: Int32, completion: @escaping (UomEntity) -> Void) {
        FirebaseService.data.getParametredUom(for: uomId, completion: { (result) in
            switch result {
            case let .success(parametredUom):
                
                completion(parametredUom)
                
            case let .failure(error):
                fatalError(error.localizedDescription)
            }
        })
    }
    
//    private func getProductInfo(for item: ShoplistItemEntity, completion: @escaping (ShoplistViewItem?, Error?) -> Void) {
//        var shopListItem = ShoplistViewItem()
//        
//        self.getProductEntity(for: item.productId) { [weak self] (result) in
//            guard let `self` = self else { return }
//            switch result {
//            case let .success(productEntity):
//                shopListItem.productId = productEntity.id
//                shopListItem.productName =  productEntity.name
//                shopListItem.country = productEntity.country
//                shopListItem.brand = productEntity.brand
//                shopListItem.weightPerPiece = productEntity.weightPerPiece
//                shopListItem.categoryId = productEntity.categoryId
//                shopListItem.uomId = productEntity.uomId
//                
//                let additionaInfoGroup = DispatchGroup()
//                additionaInfoGroup.enter()
//                self.getParametredUom(for: productEntity.uomId, completion: { (parametredUom) in
//                    shopListItem.productUom = parametredUom.name
//                    shopListItem.parameters = parametredUom.parameters
//                    additionaInfoGroup.leave()
//                })
//                
//                additionaInfoGroup.enter()
//                self.getCategoryName(for: productEntity.categoryId, completion: { (result) in
//                    switch result {
//                    case let .success(categoryName):
//                        shopListItem.productCategory = categoryName ?? "No category"
//                        additionaInfoGroup.leave()
//                    case let .failure(error):
//                        completion(nil, error)
//                    }
//                })
//                
//                additionaInfoGroup.notify(queue: .main) {
//                    completion(shopListItem, nil)
//                }
//                
//            case let .failure(error):
//                completion(nil, error)
//            }
//        }
//    }
    func getItem(with barcode: String, callback: @escaping (ProductEntity?) -> Void) {
        self.getProductFromCloud(with: barcode) { (item) in
            guard let item = item else {
                callback(nil)
                return
            }
            let result = ProductEntity(id: item.id,
                                         name: item.name,
                                         brand: item.brand,
                                         weightPerPiece: item.weightPerPiece,
                                         categoryId: item.categoryId,
                                         uomId: item.uomId,
                                         country: item.country)
            callback(result)
        }
    }
    
    private func getProductFromCloud(with productId: String, callback: @escaping (ProductEntity?) -> Void) {
        FirebaseService.data.getProduct(with: productId) { (item) in
            callback(item)
        }
    }
}
