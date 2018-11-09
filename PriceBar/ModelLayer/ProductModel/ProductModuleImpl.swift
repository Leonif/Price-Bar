//
//  ProductModuleImpl.swift
//  PriceBar
//
//  Created by Leonid Nifantyev on 10/26/18.
//  Copyright © 2018 LionLife. All rights reserved.
//

import Foundation

typealias ProductModelResult<T> = ResultType<T, ProductModelError>

class ProductModelImpl: ProductModel {
    
    var provider: BackEndInterface!
    
    func getProductInfoList(for ids: [String], completion: @escaping (([String: ProductEntity]) -> Void)) {
        var productEntities: [String: ProductEntity] = [:]
        let entityGroup = DispatchGroup()
        for productId in ids {
            entityGroup.enter()
            self.getProductEntity(for: productId, completion: { result in
                switch result {
                case let .success(entity):
                    productEntities[productId] = entity
                    entityGroup.leave()
                case let .failure(error):
                    fatalError(error.errorDescription)
                }
            })
        }
        entityGroup.notify(queue: .main) {
            completion(productEntities)
        }
    }
    
    func getProductDetail(productId: String, outletId: String, completion: @escaping (ProductModelResult<ShoplistViewItem>) -> Void) {
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
            self.getCategoryName(for: entity.categoryId!) { (result) in
                switch result {
                case let .success(name):
                    categoryName = name
                    otherProductInfoGroup.leave()
                case let .failure(error):
                    fatalError(error.errorDescription)
                }
            }
            
            otherProductInfoGroup.enter()
            self.getParametredUom(for: entity.uomId!) { (entity) in
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
            let newItem = ShoplistViewItem(productId: productEntity.productId, country: country,
                                           productName: productEntity.name,
                                           brand: productEntity.brand ?? "",
                                           weightPerPiece: productEntity.weightPerPiece ?? "",
                                           categoryId: productEntity.categoryId ?? 1,
                                           productCategory: categoryName,
                                           productPrice: price,
                                           uomId: productEntity.uomId ?? 1,
                                           productUom: parametredUom.name,
                                           quantity: 1.0,
                                           parameters: parametredUom!.params)
            
            completion(ResultType.success(newItem))
        }
    }
    
    func getQuantityOfProducts(completion: @escaping (ProductModelResult<Int>) -> Void) {
        provider.getProductCount { (result) in
            switch result {
            case let .success(count):
                completion(ResultType.success(count))
            case let .failure(error):
                completion(ResultType.failure(ProductModelError.other(error.localizedDescription)))
            }
        }
    }
    
    func savePrice(for productId: String, statistic: PriceStatisticViewItem) {
        let entity = PriceItemEntity(productId: statistic.productId,
                                     price: statistic.newPrice,
                                     outletId: statistic.outletId)
        provider.savePrice(for: productId, statistic: entity)
    }
    
    func save(new product: ProductEntity) {
        let entity = ProductEntity(productId: product.productId,
                                   name: product.name,
                                   brand: product.brand!,
                                   weightPerPiece: product.weightPerPiece!,
                                   categoryId: product.categoryId!,
                                   uomId: product.uomId!)
        provider.saveOrUpdate(entity)
    }
    
    func update(_ product: ProductEntity) {
        let entity = ProductEntity(productId: product.productId,
                                   name: product.name,
                                   brand: product.brand!,
                                   weightPerPiece: product.weightPerPiece!,
                                   categoryId: product.categoryId!,
                                   uomId: product.uomId!)
        provider.saveOrUpdate(entity)
    }
    
    func getProductList(with pageOffset: Int, limit: Int, for outletId: String, completion: @escaping (ProductModelResult<[ProductEntity]>) -> Void) {
        provider.getProductList(with: pageOffset, limit: limit) { (result) in
            switch result {
            case let .success(products):
                completion(ResultType.success(products))
            case let .failure(error):
                completion(ResultType.failure(ProductModelError.other(error.localizedDescription)))
            }
        }
    }
    
    func getPricesFor(productId: String, completion: @escaping ([ProductPrice]) -> Void) {
        provider.getPricesFor(productId) { (statistics) in
            let prices = statistics.map {
                return ProductPrice(productId: productId, productName: "",
                                    currentPrice: $0.price,
                                    outletId: $0.outletId,
                                    date: $0.date!)
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
        
        let priceGroup = DispatchGroup()
        for id in ids {
            priceGroup.enter()
            self.getPrice(for: id, and: outletId) { (price) in
                prices[id] = price
                priceGroup.leave()
            }
        }
        priceGroup.notify(queue: .main) {
            completion(prices)
        }
    }
    
    func getCountry(for productId: String, completion: @escaping (String?) -> Void) {
        provider.getCountry(for: productId) { (country) in
            completion(country)
        }
    }
    
    private func getPriceFromCloud(for productId: String, and outletId: String, completion: @escaping (Double?) -> Void) {
        provider.getLastPrice(with: productId, outletId: outletId) { (price) in
            completion(price)
        }
    }
    
    func filterItemList(contains text: String, for outletId: String, completion: @escaping (ProductModelResult<[ProductEntity]>) -> Void) {
        provider.getFiltredProductList(with: text) { (result) in
            switch result {
            case let .success(products):
                completion(ResultType.success(products))
            case let .failure(error):
                completion(ResultType.failure(ProductModelError.other(error.localizedDescription)))
            }
        }
    }
    
    func getProductName(for productId: String, completion: @escaping (ProductModelResult<String?>) -> Void) {
        provider.getProduct(with: productId) { (fbProductEntity) in
            completion(ResultType.success(fbProductEntity?.fullName))
        }
    }
    
    func getProductEntity(for productId: String, completion: @escaping (ProductModelResult<ProductEntity>) -> Void) {
        provider.getProduct(with: productId) { (fbProductEntity) in
            guard let fbProductEntity = fbProductEntity else {
                let message = R.string.localizable.error_something_went_wrong()
                completion(ResultType.failure(ProductModelError.other(message)))
                return
            }
            completion(ResultType.success(fbProductEntity))
        }
    }
    
    func getCategoryList(completion: @escaping (ProductModelResult<[CategoryEntity]>) -> Void) {
        provider.getCategoryList { (result) in
            switch result {
            case let .success(categoryList):
                guard let categoryList = categoryList else {
                    completion (ResultType.success([]))
                    return
                }
                
                let entity: [CategoryEntity] = categoryList.map { CategoryEntity(id: $0.id, name: $0.name) }
                completion(ResultType.success(entity))
                
            case let .failure(error):
                completion(ResultType.failure(.other(error.localizedDescription)))
            }
        }
    }
    
    func getUomList(completion: @escaping (ProductModelResult<[UomViewItem]?>) -> Void) {
        provider.getUomList { (result) in
            switch result {
            case let .success(uomList):
                guard let uomList = uomList else {
                    completion (ResultType.success(nil))
                    return
                }
                let item: [UomViewItem] = uomList.map { UomMapper.transform(input: $0)  }
                completion(ResultType.success(item))
                
            case let .failure(error):
                completion(ResultType.failure(.other(error.localizedDescription)))
            }
        }
    }
    
    func getCategoryId(for categoryName: String, completion: @escaping (ProductModelResult<Int?>) -> Void) {
        provider.getCategoryId(for: categoryName) { (result) in
            switch result {
            case let .success(categoryId):
                completion(ResultType.success(categoryId))
            case let .failure(error):
                completion(ResultType.failure(.other(error.localizedDescription)))
            }
        }
    }
    
    func getUomId(for uomName: String, completion: @escaping (ProductModelResult<Int?>) -> Void) {
        provider.getUomId(for: uomName) { (result) in
            switch result {
            case let .success(uomId):
                completion(ResultType.success(uomId))
            case let .failure(error):
                completion(ResultType.failure(.other(error.localizedDescription)))
            }
        }
    }
    
    func getUomName(for uomId: Int32, completion: @escaping (ProductModelResult<String>) -> Void) {
        provider.getUomName(for: uomId) { (result) in
            switch result {
            case let .success(uomName):
                completion(ResultType.success(uomName))
            case let .failure(error):
                completion(ResultType.failure(.other(error.localizedDescription)))
            }
        }
    }
    
    func getCategoryName(for categoryId: Int32, completion: @escaping (ProductModelResult<String>) -> Void) {
        provider.getCategoryName(for: categoryId) { (result) in
            switch result {
            case let .success(categoryName):
                completion(ResultType.success(categoryName))
            case let .failure(error):
                completion(ResultType.failure(.other(error.localizedDescription)))
            }
        }
    }
    
    func getParametredUom(for uomId: Int32, completion: @escaping (UomEntity) -> Void) {
        provider.getParametredUom(for: uomId, completion: { (result) in
            switch result {
            case let .success(parametredUom):
                completion(parametredUom)
            case let .failure(error):
                fatalError(error.localizedDescription)
            }
        })
    }
    
    func getItem(with barcode: String, callback: @escaping (ProductEntity?) -> Void) {
        self.getProductFromCloud(with: barcode) { (item) in
            callback(item)
        }
    }
    
    private func getProductFromCloud(with productId: String, callback: @escaping (ProductEntity?) -> Void) {
        provider.getProduct(with: productId) { (item) in
            callback(item)
        }
    }
}
