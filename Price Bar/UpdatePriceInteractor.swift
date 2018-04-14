//
//  UpdatePriceInteractor.swift
//  PriceBar
//
//  Created by Leonid Nifantyev on 4/14/18.
//  Copyright © 2018 LionLife. All rights reserved.
//

import Foundation


public final class UpdatePriceInteractor {
    
    private let repository: Repository!
    
    init(repository: Repository) {
        self.repository = repository
    }
    
    
    func updatePrice(for productId: String, price: Double, outletId: String) {
        
        let dpStatModel = DPPriceStatisticModel(outletId: outletId,
                                                productId: productId,
                                                price: price, date: Date())
        self.repository.save(new: dpStatModel)
    }
    
    
    func getPrice(for productId: String, in outletId: String) -> Double {
        return self.repository.getPrice(for: productId, and: outletId)
    }
    
    func getProductName(for productId: String) -> String {
        return self.repository.getProductName(for: productId)!
    }
    
    func getPriceStatistics(for productId: String, completion: @escaping (ResultType<[StatisticModel], RepositoryError>) -> Void) {
        let outletService = OutletService()
        var statistic: [StatisticModel] = []
        
        let stat = repository.getPricesStatisticByOutlet(for: productId)
        let productName = repository.getProductName(for: productId)!
        let dispatchGroup = DispatchGroup()
        
        stat.forEach { s in
            
            dispatchGroup.enter()
            
            outletService.getOutlet(with: s.outletId, completion: { (result) in
                switch result {
                case let .success(outlet):
                    statistic.append(StatisticModel(productId: s.productId, productName: productName,
                                                    outlet: outlet,
                                                    price: s.price,
                                                    date: s.date))
                    dispatchGroup.leave()
                case let .failure(error):
                    completion(ResultType.failure(.statisticError(error.localizedDescription)))
                    return
                }
            })
        }
        dispatchGroup.notify(queue: .main) {
            statistic.sort(by: { $0.date > $1.date })
            completion(ResultType.success(statistic))
        }
    }
    

}
