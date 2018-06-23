//
//  UpdatePriceInteractor.swift
//  PriceBar
//
//  Created by Leonid Nifantyev on 4/14/18.
//  Copyright © 2018 LionLife. All rights reserved.
//

import Foundation


protocol UpdatePriceOutput {
    func saved()
}



protocol UpdatePricePresenter {
    func onSavePrice(for productId: String, for outletId: String, with newPrice: Double, and oldPrice: Double)
    func onGetProductInfo(for productId: String, and outletId: String)
    func onGetPriceStatistics(for productId: String)
}

public final class UpdatePricePresenterImpl: UpdatePricePresenter {
    
    var repository: Repository!
    weak var view: UpdatePriceView!
    var updatePriceOutput: UpdatePriceOutput!
    
    func onGetProductInfo(for productId: String, and outletId: String) {
        self.view.showLoading(with: "Получаем информацию о продукте")
        return self.repository.getPrice(for: productId, and: outletId, callback: { (price) in
            let uomName = self.repository.getUomName(for: productId)
            let name = self.repository.getProductName(for: productId)!
            self.view.hideLoading()
            self.view.onGetProductInfo(price: price, name: name, uomName: uomName)
        })
    }
    
    func onSavePrice(for productId: String, for outletId: String, with newPrice: Double, and oldPrice: Double) {
        defer { self.view.close() }
        guard newPrice != oldPrice && newPrice != 0
            else { return  }
        let dpStatModel = DPPriceStatisticModel(outletId: outletId,
                                                productId: productId,
                                                price: newPrice, date: Date())
        self.repository.save(new: dpStatModel)
        self.updatePriceOutput.saved()
    }
    
    func onGetPriceStatistics(for productId: String) {
        let outletService = OutletService()
        var statistic: [StatisticModel] = []
        
        
        self.view.showLoading(with: "Получаем историю цен")
        // FIXME: get price from cloud
        let cdPriceStatistics = repository.getPricesStatisticByOutlet(for: productId)
        let productName = repository.getProductName(for: productId)!
        let dispatchGroup = DispatchGroup()
        
        cdPriceStatistics.forEach { cdPriceStatistic in
            dispatchGroup.enter()
            outletService.getOutlet(with: cdPriceStatistic.outletId, completion: { (result) in
                
                switch result {
                case let .success(outlet):
                    statistic.append(StatisticModel(productId: cdPriceStatistic.productId,
                                                    productName: productName,
                                                    outlet: outlet,
                                                    price: cdPriceStatistic.price,
                                                    date: cdPriceStatistic.date))
                    dispatchGroup.leave()
                case let .failure(error):
                    self.view.hideLoading()
                    self.view.onError(with: error.localizedDescription)
                }
            })
        }
        
        dispatchGroup.notify(queue: .main) {
            self.view.hideLoading()
            statistic.sort(by: { $0.date > $1.date })
            self.view.onGetStatistics(statistic: statistic)
        }
    }
}
