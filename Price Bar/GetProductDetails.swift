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
        self.repository.getItem(with: productId) { [weak self] (productEntity) in
            guard let productEntity = productEntity else { fatalError() }
            self?.repository.getPrice(for: productId, and: outletId) { [weak self] (price) in
                guard let `self` = self else { return }
                self.repository.getCategoryName(for: productEntity.categoryId, completion: { [weak self] (result) in
                    switch result {
                    case let .success(categoryName):
                        guard let categoryName = categoryName else {
                            completion(ResultType.failure(RepositoryError.other(R.string.localizable.error_something_went_wrong())))
                            return
                        }
                        self?.repository.getParametredUom(for: productEntity.uomId, completion: { (fbUom) in
                            let newItem = ShoplistItem(productId: productEntity.id,
                                                       productName: productEntity.name,
                                                       brand: productEntity.brand,
                                                       weightPerPiece: productEntity.weightPerPiece,
                                                       categoryId: productEntity.categoryId,
                                                       productCategory: categoryName,
                                                       productPrice: price,
                                                       uomId: productEntity.uomId,
                                                       productUom: fbUom.name, quantity: 1.0, parameters: fbUom.parameters)
                            completion(ResultType.success(newItem))
                        })
                    case let .failure(error):
                        completion(ResultType.failure(error))
                    }
                })
            }
        }
    }
}
