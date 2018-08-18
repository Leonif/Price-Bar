//
//  GetProductDetails.swift
//  PriceBar
//
//  Created by LEONID NIFANTIJEV on 7/17/18.
//  Copyright © 2018 LionLife. All rights reserved.
//

import Foundation

class GetProductDetailsProvider {
    
    let productModel: ProductModel!
    
    init(productModel: ProductModel) {
        self.productModel = productModel
    }
    
    func getProductDetail(productId: String, outletId: String, completion: @escaping (ResultType<ShoplistItem, ProductModelError>) -> Void) {
        
        let productInfo = DispatchGroup()
        var productEntity: DPProductEntity!
        var categoryName: String!
        var country: String!
        var parametredUom: FBUomModel!
        var price: Double!
        
        productInfo.enter()
        self.productModel.getItem(with: productId, callback: { (entity) in
            productEntity = entity
            let uomAndCategoryGroup = DispatchGroup()
            
            guard let entity = entity else { fatalError() }
            
            uomAndCategoryGroup.enter()
            self.productModel.getCategoryName(for: entity.categoryId) { (result) in
                switch result {
                case let .success(name):
                    categoryName = name
                    uomAndCategoryGroup.leave()
                case let .failure(error):
                    fatalError(error.errorDescription)
                }
            }

            uomAndCategoryGroup.enter()
            self.productModel.getParametredUom(for: entity.uomId) { (entity) in
                parametredUom = entity
                uomAndCategoryGroup.leave()
            }
            
            uomAndCategoryGroup.notify(queue: .main) {
                productInfo.leave()
            }
        })

        productInfo.enter()
        self.productModel.getPrice(for: productId, and: outletId) { (value) in
            price = value
            productInfo.leave()
        }
        
        productInfo.enter()
        self.productModel.getCountry(for: productId) { (value) in
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
