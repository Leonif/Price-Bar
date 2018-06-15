//
//  ShoplistInteractor.swift
//  PriceBar
//
//  Created by Leonid Nifantyev on 2/26/18.
//  Copyright © 2018 LionLife. All rights reserved.
//

import Foundation
import GooglePlaces


public final class ShoplistPresenter {
    private let outletService = OutletService()
    private let repository: Repository!
    var onIsProductHasPrice: ((Bool, String) -> Void) = { _,_  in}
    
    init(repository: Repository) {
        self.repository = repository
    }
    
    public func updateCurrentOutlet(completion: @escaping (ResultType<Outlet, OutletServiceError>) -> Void) {
        let outletService = OutletService()
        outletService.nearestOutlet { result in
            switch result {
            case let .success(outlet):
                let outlet = OutletMapper.mapper(from: outlet)
                completion(ResultType.success(outlet))
            case let .failure(error):
                completion(ResultType.failure(error))
            }
        }
    }
    
    func synchronizeData(completion: @escaping (ResultType<Bool, RepositoryError>) -> Void) {
        repository.syncCloud { result in
            switch result {
            case let .failure(error):
                completion(ResultType.failure(error))
            case .success:
                completion(ResultType.success(true))
            }
        }
    }
    
    func addToShoplist(with productId: String, and outletId: String, completion: @escaping (ResultType<Bool, RepositoryError>) -> Void) {
//        guard let product: DPProductModel = repository.getItem(with: productId, and: outletId) else {
//            completion(ResultType.failure(RepositoryError.productIsNotFound("")))
//            return
//        }
        
        repository.getItem(with: productId, and: outletId) { (product) in
            
            guard let product = product else { fatalError() }
            
            self.addItemToShopList(product, and: outletId, completion: { result in
                switch result {
                case let .failure(error):
                    completion(ResultType.failure(error))
                case .success:
                    completion(ResultType.success(true))
                }
            })
        }
    }
    
    private func addItemToShopList(_ product: DPProductModel, and outletId: String, completion: @escaping (ResultType<Bool, RepositoryError>)-> Void) {
        
        repository.getPrice(for: product.id, and: outletId) { [weak self] (price) in
            guard let `self` = self else { return }
            
            let shopListItem: DPShoplistItemModel = ProductMapper.mapper(from: product, price: price)
            
            let result = self.repository.saveToShopList(new: shopListItem)
            switch result {
            case let .failure(error):
                completion(ResultType.failure(error))
            case .success:
                completion(ResultType.success(true))
                
            }
        }
        
        
    }
    
    func isProductHasPrice(for productId: String, in outletId: String) {
        self.repository.getPrice(for: productId, and: outletId, callback: { [weak self] (price) in
            self?.onIsProductHasPrice(price > 0.0, productId)
            
        })
    }
    
    func reloadProducts(outletId: String) {
        self.repository.loadShopList(for: outletId)
    }
}
