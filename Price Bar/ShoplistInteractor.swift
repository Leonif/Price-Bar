//
//  ShoplistInteractor.swift
//  PriceBar
//
//  Created by Leonid Nifantyev on 2/26/18.
//  Copyright © 2018 LionLife. All rights reserved.
//

import Foundation


public final class ShoplistInteractor {
    private let outletService = OutletService()
    private let repository: Repository!
    
    init(repository: Repository) {
        self.repository = repository
    }
    
    
    public func updateCurrentOutlet(completion: @escaping (ResultType<Outlet, OutletServiceError>) -> Void) {
        let outletService = OutletService()
        outletService.nearestOutlet { result in
            print(result)
            switch result {
            case let .success(outlet):
                let outlet = OutletFactory.mapper(from: outlet)
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
        guard let product: DPProductModel = repository.getItem(with: productId, and: outletId) else {
            completion(ResultType.failure(RepositoryError.productIsNotFound("")))
            return
        }
        addItemToShopList(product, and: outletId, completion: { result in
            switch result {
            case let .failure(error):
                completion(ResultType.failure(error))
            case .success:
                completion(ResultType.success(true))
            }
        })
        
    }
    
    private func addItemToShopList(_ product: DPProductModel, and outletId: String, completion: (ResultType<Bool, RepositoryError>)-> Void) {
        
        let shopListItem: DPShoplistItemModel = ProductMapper.mapper(from: product, and: outletId)
        
        let result = repository.saveToShopList(new: shopListItem)
        switch result {
        case let .failure(error):
            completion(ResultType.failure(error))
        case .success:
            
            self.getPriceStatistics(for: product.id)
            
            completion(ResultType.success(true))
        
        }
    }
    
    private func getPriceStatistics(for productId: String) {
        
        let outletService = OutletService()
        var statDict: [String: Double] = [:]
        
        
        let stat = repository.getPricesStatisticByOutlet(for: productId)
        stat.forEach { s in
            let outletId = s.key
            outletService.getOutlet(with: outletId, completion: { (result) in
                switch result {
                case let .success(outlet):
                    print(outlet)
                    statDict[outlet.name] = s.value
                case let .failure(error):
                    print(error.localizedDescription)
                }
            })

        }
        print(stat)
        
        
        
    }
    
    
    
    func reloadProducts(outletId: String) {
        repository.loadShopList(for: outletId)
    }
    
    
    func getQuantityOfGood() -> Int {
        return repository.getQuantityOfProducts()
    }
    
    
    
}
