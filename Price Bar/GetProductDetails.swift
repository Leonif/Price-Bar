//
//  GetProductDetails.swift
//  PriceBar
//
//  Created by LEONID NIFANTIJEV on 7/17/18.
//  Copyright © 2018 LionLife. All rights reserved.
//

import Foundation

class GetProductDetailsProvider {
    
    let repository: Repository!
    
    init(repository: Repository) {
        self.repository = repository
    }
    
    func getProductDetail2(productId: String, outletId: String, completion: @escaping (ResultType<ShoplistItem, RepositoryError>) -> Void) {
        
        let operationQueue = OperationQueue()
        operationQueue.maxConcurrentOperationCount = 1
        
        
        var productEntity: DPProductEntity!
        let productOperation = BlockOperation {
            self.repository.getItem(with: productId, callback: { (entity) in
                guard let entity = entity else { fatalError() }
                productEntity = entity
            })
        }
        
        
        productOperation.completionBlock = {
            debugPrint("productOpearation")
        }
    
        var price: Double!
        let priceOperation = BlockOperation {
            self.repository.getPrice(for: productId, and: outletId) { (value) in
                price = value
            }
        }
        
        var categoryName: String!
        let categoryOperaion = BlockOperation {
            self.repository.getCategoryName(for: productEntity.categoryId) { (result) in
                switch result {
                case let .success(name):
                    categoryName = name
                case let .failure(error):
                    fatalError(error.errorDescription)
                }
            }
        }
        
//        categoryOperaion.addDependency(productOperation)
        
        var parametredUom: FBUomModel!
        let uomOperaion = BlockOperation {
            self.repository.getParametredUom(for: productEntity.uomId) { (entity) in
                parametredUom = entity
            }
        }
        
//        uomOperaion.addDependency(productOperation)
        
        
        operationQueue.addOperations([productOperation, priceOperation, categoryOperaion, uomOperaion], waitUntilFinished: true)
        
        
        let newItem = ShoplistItem(productId: productEntity.id,
                                   productName: productEntity.name,
                                   brand: productEntity.brand,
                                   weightPerPiece: productEntity.weightPerPiece,
                                   categoryId: productEntity.categoryId,
                                   productCategory: categoryName,
                                   productPrice: price,
                                   uomId: productEntity.uomId,
                                   productUom: parametredUom.name, quantity: 1.0, parameters: parametredUom.parameters)
        
        
        completion(ResultType.success(newItem))
        
        
    
    }
    
    
    func getProductDetail(productId: String, outletId: String, completion: @escaping (ResultType<ShoplistItem, RepositoryError>) -> Void) {
        
        let productEntityDispatchGroup = DispatchGroup()
        let dispatchGroup = DispatchGroup()
        
        var productEntity: DPProductEntity!
        productEntityDispatchGroup.enter()
        self.repository.getItem(with: productId, callback: { (entity) in
            guard let entity = entity else { fatalError() }
            productEntity = entity
            productEntityDispatchGroup.leave()
        })
        
        var parametredUom: FBUomModel!
        var categoryName: String!
        var price: Double!
       
        productEntityDispatchGroup.enter()
        self.repository.getPrice(for: productId, and: outletId) { (value) in
            price = value
            productEntityDispatchGroup.leave()
        }
        
        productEntityDispatchGroup.notify(queue: .main) {
            dispatchGroup.enter()
            self.repository.getCategoryName(for: productEntity.categoryId) { (result) in
                switch result {
                case let .success(name):
                    categoryName = name
                    dispatchGroup.leave()
                case let .failure(error):
                    fatalError(error.errorDescription)
                }
            }
            dispatchGroup.enter()
            self.repository.getParametredUom(for: productEntity.uomId) { (entity) in
                parametredUom = entity
                dispatchGroup.leave()
            }
            
            dispatchGroup.notify(queue: .main) {
                let newItem = ShoplistItem(productId: productEntity.id,
                                           productName: productEntity.name,
                                           brand: productEntity.brand,
                                           weightPerPiece: productEntity.weightPerPiece,
                                           categoryId: productEntity.categoryId,
                                           productCategory: categoryName,
                                           productPrice: price,
                                           uomId: productEntity.uomId,
                                           productUom: parametredUom.name, quantity: 1.0, parameters: parametredUom.parameters)
                completion(ResultType.success(newItem))
            }
        }
    }
}
