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
    
    func getProductDetail(productId: String, outletId: String, completion: @escaping (ResultType<ShoplistItem, RepositoryError>) -> Void) {
        
        let productInfo = DispatchGroup()
        var productEntity: DPProductEntity!
        var categoryName: String!
        var country: String!
        var parametredUom: FBUomModel!
        var price: Double!
        
        productInfo.enter()
        self.repository.getItem(with: productId, callback: { (entity) in
            productEntity = entity
            let uomAndCategoryGroup = DispatchGroup()
            
            guard let entity = entity else { fatalError() }
            
            uomAndCategoryGroup.enter()
            self.repository.getCategoryName(for: entity.categoryId) { (result) in
                switch result {
                case let .success(name):
                    categoryName = name
                    uomAndCategoryGroup.leave()
                case let .failure(error):
                    fatalError(error.errorDescription)
                }
            }

            uomAndCategoryGroup.enter()
            self.repository.getParametredUom(for: entity.uomId) { (entity) in
                parametredUom = entity
                uomAndCategoryGroup.leave()
            }
            
            uomAndCategoryGroup.notify(queue: .main) {
                productInfo.leave()
            }
        })

        productInfo.enter()
        self.repository.getPrice(for: productId, and: outletId) { (value) in
            price = value
            productInfo.leave()
        }
        
        productInfo.enter()
        self.repository.getCountry(for: productId) { (value) in
            country = value
            productInfo.leave()
        }
        
        productInfo.notify(queue: .main) {
            let newItem = ShoplistItem(productId: productEntity.id, country: country,
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
}
