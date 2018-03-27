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
        self.addItemToShopList(product, and: outletId, completion: { result in
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
            completion(ResultType.success(true))
        
        }
    }
    
    // TODO: return Statistic
    func getPriceStatistics(for productId: String, completion: @escaping (ResultType<StatisticModel, RepositoryError>) -> Void) {
        let outletService = OutletService()
        var statistic: StatisticModel = StatisticModel()

        let stat = repository.getPricesStatisticByOutlet(for: productId)
        let dispatchGroup = DispatchGroup()
        dispatchGroup.enter()
        for (key, value) in stat {
            let outletId = key
            outletService.getOutlet(with: outletId, completion: { (result) in
                switch result {
                case let .success(outlet):
                    statistic.productId = productId
                    statistic.append(outlet, value)
                    if statistic.outlets.count == stat.count {
                        dispatchGroup.leave()
                    }
                case let .failure(error):
                    completion(ResultType.failure(.statisticError(error.localizedDescription)))
                    return
                }
            })
        }
        dispatchGroup.notify(queue: .main) {
            completion(ResultType.success(statistic))
        }
    }
    
    
    
    func reloadProducts(outletId: String) {
        repository.loadShopList(for: outletId)
    }
    
    
    func getQuantityOfGood() -> Int {
        return repository.getQuantityOfProducts()
    }
    
    
    
}
